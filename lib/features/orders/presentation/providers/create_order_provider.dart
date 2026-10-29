import 'package:flutter/foundation.dart';

import '../../data/models/create_order_payload.dart';
import '../../data/models/order_item_payload.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_menu_item_entity.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_available_menu_items_usecase.dart';

enum CreateOrderStatus { initial, loading, ready, error }

class CreateOrderProvider extends ChangeNotifier {
  final GetAvailableMenuItemsUsecase getAvailableMenuItemsUsecase;
  final CreateOrderUsecase createOrderUsecase;

  CreateOrderProvider(
    this.getAvailableMenuItemsUsecase,
    this.createOrderUsecase,
  );

  // status memuat daftar menu (bukan status submit)
  CreateOrderStatus status = CreateOrderStatus.initial;
  String? errorMessage;

  // status submit dipisah supaya tidak bentrok dengan status memuat menu
  bool isSubmitting = false;
  String? submitError;
  OrderEntity? createdOrder;

  final Map<int, int> _cart = {}; // menuItemId -> quantity
  List<OrderMenuItemEntity> _menuItems = [];

  Map<int, int> get cart => _cart;
  List<OrderMenuItemEntity> get menuItems => _menuItems;

  double get cartTotal {
    double total = 0;
    _cart.forEach((id, qty) {
      final item = _menuItems.firstWhere((m) => m.id == id);
      total += item.price * qty;
    });
    return total;
  }

  int get cartCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  Future<void> loadMenuItems() async {
    status = CreateOrderStatus.loading;
    notifyListeners();
    try {
      _menuItems = await getAvailableMenuItemsUsecase();
      status = CreateOrderStatus.ready;
    } catch (e) {
      errorMessage = e.toString();
      status = CreateOrderStatus.error;
    }
    notifyListeners();
  }

  void setQuantity(int menuItemId, int quantity) {
    if (quantity <= 0) {
      _cart.remove(menuItemId);
    } else {
      _cart[menuItemId] = quantity;
    }
    notifyListeners();
  }

  void incrementQuantity(int menuItemId) =>
      setQuantity(menuItemId, (_cart[menuItemId] ?? 0) + 1);
  void decrementQuantity(int menuItemId) =>
      setQuantity(menuItemId, (_cart[menuItemId] ?? 0) - 1);

  Future<void> submit({
    required String orderType,
    String? tableNumber,
    String? customerName,
    String? notes,
  }) async {
    if (_cart.isEmpty) {
      submitError = 'Keranjang masih kosong, pilih menu dulu ya.';
      notifyListeners();
      return;
    }

    isSubmitting = true;
    submitError = null;
    notifyListeners();

    try {
      final payload = CreateOrderPayload(
        orderType: orderType,
        tableNumber: tableNumber,
        customerName: customerName,
        notes: notes,
        items: _cart.entries
            .map((e) => OrderItemPayload(menuItemId: e.key, quantity: e.value))
            .toList(),
      );
      createdOrder = await createOrderUsecase(payload);
      _cart.clear();
    } catch (e) {
      submitError = e.toString();
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
