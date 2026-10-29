import 'package:flutter/foundation.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/features/orders/data/models/create_order_payload.dart';
import 'package:restauran_menu/features/orders/data/models/order_item_payload.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/features/orders/domain/usecases/create_order_usecase.dart';

import '../../domain/entities/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final CreateOrderUsecase createOrderUsecase;

  /// Dibaca lazy dari SharedPref (bukan `static ... = getPPN()` di field
  /// initializer) supaya provider bisa dibuat sebelum
  /// `SharedPrefServices.init()` selesai — kalau tidak, muncul
  /// `SharedPrefServices is not Initialized` saat MultiProvider create.
  static double get taxRate => getPPN(calculate: true);

  List<CartItem> items = [];
  String? paymentMethod;
  String? orderNumber;
  String? tableNumber;
  String? customerName;
  String? address;
  String? phone;
  String? notes;
  String orderType = OrderEntity.typeDineIn;

  CartProvider(this.createOrderUsecase);

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  int get tax => (subtotal * taxRate).round();
  int get total => subtotal; // + tax;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  void addItem(MenuItemEntity menuItem, {int quantity = 1}) {
    final list = [...items];
    final index = list.indexWhere((c) => c.menuItem.id == menuItem.id);
    if (index >= 0) {
      list[index] = list[index].copyWith(
        quantity: list[index].quantity + quantity,
      );
    } else {
      list.add(CartItem(menuItem: menuItem, quantity: quantity));
    }
    items = list;
    notifyListeners();
  }

  void incrementQuantity(int menuItemId) {
    items = items
        .map(
          (c) => c.menuItem.id == menuItemId
              ? c.copyWith(quantity: c.quantity + 1)
              : c,
        )
        .toList();
    notifyListeners();
  }

  void decrementQuantity(int menuItemId) {
    final list = <CartItem>[];
    for (final c in items) {
      if (c.menuItem.id == menuItemId) {
        if (c.quantity > 1) list.add(c.copyWith(quantity: c.quantity - 1));
        // quantity reaches 0 -> item removed from cart
      } else {
        list.add(c);
      }
    }
    items = list;
    notifyListeners();
  }

  void removeItem(int menuItemId) {
    items = items.where((c) => c.menuItem.id != menuItemId).toList();
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  void setOrderNumber(String number) {
    orderNumber = number;
    notifyListeners();
  }

  void setCustomerInfo({
    String? tableNumber,
    String? customerName,
    String? address,
    String? phone,
    String? notes,
    String? orderType,
  }) {
    this.tableNumber = tableNumber;
    this.customerName = customerName;
    this.address = address;
    this.phone = phone;
    this.notes = notes;
    if (orderType != null) this.orderType = orderType;
    notifyListeners();
  }

  void setTableNumber(String? value) {
    tableNumber = value;
    notifyListeners();
  }

  void setCustomerName(String? value) {
    customerName = value;
    notifyListeners();
  }

  void setCustomerAddress(String? value) {
    address = value;
    notifyListeners();
  }

  void setCustomerPhone(String? value) {
    phone = value;
    notifyListeners();
  }

  void setNotes(String? value) {
    notes = value;
    notifyListeners();
  }

  void setOrderType(String value) {
    orderType = value;
    notifyListeners();
  }

  void clear() {
    items = [];
    paymentMethod = null;
    orderNumber = null;
    tableNumber = null;
    customerName = null;
    address = null;
    phone = null;
    notes = null;
    orderType = OrderEntity.typeDineIn;
    notifyListeners();
  }

  int quantityOf(int menuItemId) {
    final match = items.where((c) => c.menuItem.id == menuItemId);
    if (match.isEmpty) return 0;
    return match.first.quantity;
  }

  Future<OrderEntity?> submit({
    required String orderType,
    String? tableNumber,
    String? customerName,
    String? paymentMethod,
    String? address,
    String? phone,
    String? notes,
    String? sources,
    required List<CartItem> items,
  }) async {
    try {
      final payload = CreateOrderPayload(
        orderType: orderType,
        tableNumber: tableNumber,
        customerName: customerName,
        paymentMethod: paymentMethod,
        sources: sources,
        notes: notes,
        address: address,
        phone: phone,
        items: items
            .map(
              (e) => OrderItemPayload(
                menuItemId: e.menuItem.id,
                quantity: e.quantity,
              ),
            )
            .toList(),
      );
      final success = await createOrderUsecase(payload);
      return success;
    } finally {
      notifyListeners();
    }
  }
}
