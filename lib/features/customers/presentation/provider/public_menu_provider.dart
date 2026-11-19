import 'package:flutter/foundation.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_entity.dart';
import 'package:restauran_menu/features/customers/data/models/public_menu_response.dart';
import 'package:restauran_menu/features/customers/domain/usecases/cancel_public_order_usecase.dart';
import 'package:restauran_menu/features/customers/domain/usecases/create_public_order_usecase.dart';
import 'package:restauran_menu/features/customers/domain/usecases/get_public_menu_usecase.dart';
import 'package:restauran_menu/features/customers/domain/usecases/get_public_order_usecase.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_category_entity.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/features/orders/data/models/create_order_payload.dart';
import 'package:restauran_menu/features/orders/data/models/order_item_payload.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

import '../../domain/entities/cart_item.dart';

enum PublicMenuStatus { initial, loading, loaded, error }

class PublicMenuProvider extends ChangeNotifier {
  final GetPublicMenuUsecase getPublicMenuUsecase;
  final CreatePublicOrderUsecase createPublicOrderUsecase;
  final GetPublicOrderUsecase? getPublicOrderUsecase;
  final CancelPublicOrderUsecase? cancelPublicOrderUsecase;

  PublicMenuProvider(
    this.getPublicMenuUsecase,
    this.createPublicOrderUsecase, [
    this.getPublicOrderUsecase,
    this.cancelPublicOrderUsecase,
  ]);

  PublicMenuStatus status = PublicMenuStatus.initial;
  String? errorMessage;
  String? slug;

  TenantEntity? tenant;
  List<MenuCategoryEntity> categories = [];
  List<MenuItemEntity> items = [];

  bool isOrdering = false;
  String? orderError;

  List<OrderEntity> myOrders = [];
  bool isLoadingOrders = false;
  String? ordersError;

  List<MenuItemEntity> get favorites =>
      items.where((e) => e.isFavorite).toList();
  List<MenuItemEntity> get bannerItems =>
      items.where((e) => e.isBanner).toList();
  List<MenuItemEntity> byCategory(int? categoryId) {
    if (categoryId == null) return items;
    return items.where((e) => e.categoryId == categoryId).toList();
  }

  Future<void> load(String? rawSlug, {bool forceRefresh = false}) async {
    final s = (rawSlug ?? '').trim();
    if (s.isEmpty) {
      status = PublicMenuStatus.error;
      errorMessage = 'Slug resto kosong. Buka via QR / link resto yang valid.';
      notifyListeners();
      return;
    }
    // Ganti slug -> reset dulu supaya tidak tampilkan menu resto lama.
    if (slug != s) {
      tenant = null;
      categories = [];
      items = [];
    }
    slug = s;
    status = PublicMenuStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final PublicMenuData data = await getPublicMenuUsecase(
        s,
        forceRefresh: forceRefresh,
      );
      tenant = data.tenant;
      categories = data.categories;
      items = data.items.where((e) => e.isAvailable).toList();
      //debugPrint("items ${data.items.length}");
      debugPrint("public_menu_provider.load : $tenant!");
      await initLocalMyTenant(tenant!);
      status = PublicMenuStatus.loaded;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      status = PublicMenuStatus.error;
    }
    notifyListeners();
  }

  Future<void> silentLoad(String? rawSlug, {bool forceRefresh = false}) async {
    final s = (rawSlug ?? '').trim();
    if (s.isEmpty) {
      status = PublicMenuStatus.error;
      errorMessage = 'Slug resto kosong. Buka via QR / link resto yang valid.';
      return;
    }
    // Ganti slug -> reset dulu supaya tidak tampilkan menu resto lama.
    if (slug != s) {
      tenant = null;
      categories = [];
      items = [];
    }
    slug = s;
    status = PublicMenuStatus.loading;
    errorMessage = null;
    try {
      final PublicMenuData data = await getPublicMenuUsecase(
        s,
        forceRefresh: forceRefresh,
      );
      // debugPrint("silentLoad public menu : ${data.items}");
      tenant = data.tenant;
      categories = data.categories;
      items = data.items.where((e) => e.isAvailable).toList();
      await initLocalMyTenant(tenant!);
      status = PublicMenuStatus.loaded;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      status = PublicMenuStatus.error;
    }
  }

  Future<void> refresh() => load(slug, forceRefresh: true);

  /// POST api/menu/:slug/order dari isi keranjang.
  Future<OrderEntity?> submitCart({
    required List<CartItem> cartItems,
    required String orderType,
    String? tableNumber,
    String? customerName,
    String? paymentMethod,
    String? address,
    String? phone,
    String? notes,
  }) async {
    final s = (slug ?? '').trim();
    if (s.isEmpty) {
      orderError = 'Slug resto kosong.';
      notifyListeners();
      return null;
    }
    if (cartItems.isEmpty) {
      orderError = 'Keranjang masih kosong.';
      notifyListeners();
      return null;
    }
    isOrdering = true;
    orderError = null;
    notifyListeners();
    try {
      final payload = CreateOrderPayload(
        orderType: orderType,
        tableNumber: tableNumber,
        customerName: customerName,
        paymentMethod: paymentMethod,
        address: address,
        phone: phone,
        notes: notes,
        sources: 'customer',
        items: cartItems
            .map(
              (e) => OrderItemPayload(
                menuItemId: e.menuItem.id,
                quantity: e.quantity,
                notes: e.note,
              ),
            )
            .toList(),
      );
      final order = await createPublicOrderUsecase(s, payload);
      isOrdering = false;
      notifyListeners();
      return order;
    } catch (e) {
      isOrdering = false;
      orderError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// GET api/public/menu/:slug/my_orders
  Future<List<OrderEntity>> getPublicOrders({String? orderNumber}) async {
    final s = (slug ?? '').trim();
    if (s.isEmpty) {
      ordersError = 'Slug restoran tidak tersedia.';
      notifyListeners();
      return [];
    }
    isLoadingOrders = true;
    ordersError = null;
    notifyListeners();
    try {
      final usecase = getPublicOrderUsecase ?? sl<GetPublicOrderUsecase>();
      final orders = await usecase(s, orderNumber: orderNumber);
      myOrders = orders;
      isLoadingOrders = false;
      notifyListeners();
      return orders;
    } catch (e) {
      isLoadingOrders = false;
      ordersError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return [];
    }
  }

  /// DELETE api/public/menu/:slug/order?order_number=...
  Future<OrderEntity?> cancelPublicOrder(String orderNumber) async {
    final s = (slug ?? '').trim();
    if (s.isEmpty) {
      orderError = 'Slug resto kosong.';
      debugPrint("cancel $orderError");
      notifyListeners();
      return null;
    }
    try {
      final usecase =
          cancelPublicOrderUsecase ?? sl<CancelPublicOrderUsecase>();
      final result = await usecase(s, orderNumber);
      notifyListeners();
      return result;
    } catch (e) {
      orderError = e.toString().replaceFirst('Exception: ', '');
      debugPrint("cancel $orderError");
      notifyListeners();
      return null;
    }
  }
}
