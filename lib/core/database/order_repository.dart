import 'package:hive_ce/hive_ce.dart';

import '../../features/customers/domain/entities/cart_item.dart';
import '../../features/kasir/data/models/order_hive.dart';
import '../../features/orders/domain/entities/order_entity.dart';

/// Single source of truth for orders, backed by Hive. This is what keeps
/// Customer (creates orders), Kasir (payment), Kitchen (food-prep status)
/// and Waiter (delivery + table-side ordering) all in sync in real time:
/// every Cubit watches the same box, so a write from any one of them is
/// reflected everywhere else automatically.
class OrderRepository {
  OrderRepository(this._box);
  final Box<OrderHive> _box;

  List<OrderEntity> _readAll() {
    final entities = _box.values.map((h) => h.toEntity()).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }

  /// All orders, newest first. Emits immediately with the current data,
  /// then again on every write.
  Stream<List<OrderEntity>> watchAll() async* {
    yield _readAll();
    await for (final _ in _box.watch()) {
      yield _readAll();
    }
  }

  /// Creates a new order and returns its generated order number
  /// (e.g. `#0031`).
  ///
  /// Key Hive == [OrderHive.id] lewat sekali `put`, tanpa `add()`
  /// supaya tidak kena auto-increment Hive.
  Future<String> createOrder({
    int? tableNumber,
    required String orderType,
    required List<CartItem> items,
    String? customerName,
    String? notes,
  }) async {
    final id = _nextId();
    final orderNumber = '#${id.toString().padLeft(4, '0')}';
    final draft = OrderHive(
      id: id,
      orderNumber: orderNumber,
      tableNumber: tableNumber,
      orderTypeIndex: _orderTypeToIndex(orderType),
      statusIndex: 0,
      items: OrderHive.itemsFromCart(items),
      createdAt: DateTime.now(),
      customerName: customerName?.trim().isEmpty == true
          ? null
          : customerName?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );
    await _box.put(id, draft);
    return orderNumber;
  }

  Future<void> updateStatus(String orderNumber, String status) {
    return _mutate(orderNumber, (o) => o.statusIndex = _statusToIndex(status));
  }

  /// Records payment. By default this only marks the order as paid without
  /// forcing it completed — the Customer self-checkout flow pays first but
  /// the kitchen still needs to cook it. Pass [complete]: true for the
  /// Kasir counter flow, where processing payment also closes the order.
  Future<void> markPaid(
    String orderNumber,
    String method, {
    bool complete = false,
  }) {
    return _mutate(orderNumber, (o) {
      o.isPaid = true;
      o.paymentMethodIndex = _paymentToIndex(method);
      if (complete) o.statusIndex = _statusToIndex(OrderEntity.statusCompleted);
    });
  }

  Future<void> cancelOrder(String orderNumber) {
    return _mutate(
      orderNumber,
      (o) => o.statusIndex = _statusToIndex(OrderEntity.statusCancelled),
    );
  }

  Future<void> _mutate(
    String orderNumber,
    void Function(OrderHive order) update,
  ) async {
    OrderHive? match;
    dynamic matchKey;
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value.orderNumber == orderNumber) {
        match = value;
        matchKey = key;
        break;
      }
    }
    if (match == null) return;
    update(match);
    await _box.put(matchKey, match);
  }

  /// Populates the box with [seedOrders] the very first time the app runs
  /// (no-op if the box already has data).
  ///
  /// Key Hive == `order.id` lewat `put`, tanpa `add()` supaya tidak
  /// kena auto-increment Hive.
  Future<void> seedIfEmpty(List<OrderEntity> seedOrders) async {
    if (_box.isNotEmpty) return;
    for (final order in seedOrders) {
      final id = order.id > 0 ? order.id : _nextId();
      final draft = OrderHive(
        id: id,
        orderNumber: order.orderNumber,
        tableNumber: order.tableNumberInt,
        orderTypeIndex: _orderTypeToIndex(order.orderType),
        statusIndex: _statusToIndex(order.status),
        items: OrderHive.itemsFromEntity(order.items),
        createdAt: order.createdAt,
        paymentMethodIndex: order.paymentMethod == null
            ? null
            : _paymentToIndex(order.paymentMethod!),
        isPaid: order.isPaid,
        customerName: order.customerName,
        notes: order.notes,
      );
      await _box.put(id, draft);
    }
  }

  /// Hitung id lokal berikutnya (max key/id + 1) supaya `put(id, ...)`
  /// tetap unik tanpa memakai auto-increment `_box.add()`.
  int _nextId() {
    var max = 0;
    for (final key in _box.keys) {
      if (key is int && key > max) max = key;
      final value = _box.get(key);
      if (value != null && value.id > max) max = value.id;
    }
    return max + 1;
  }

  static int _statusToIndex(String status) {
    final i = OrderEntity.legacyStatusByIndex.indexOf(status);
    return i < 0 ? 0 : i;
  }

  static int _orderTypeToIndex(String orderType) {
    final i = OrderEntity.legacyOrderTypeByIndex.indexOf(orderType);
    return i < 0 ? 0 : i;
  }

  static int? _paymentToIndex(String method) {
    final i = OrderEntity.legacyPaymentByIndex.indexOf(method);
    if (i >= 0) return i;
    // Toleransi kode backend lama "qrcode" == qris.
    if (method == OrderEntity.payQrcode) return 0;
    return null;
  }

  Future<void> addAll(List<OrderEntity> items) async {
    for (final item in items) {
      await addItem(item);
    }
  }

  Future<void> addItem(OrderEntity item) async {
    // Key Hive == item.id (bukan auto-increment `_box.add()`).
    // Dedup tetap berdasarkan orderNumber (unik) supaya data API
    // yang id-nya beda dengan lokal tidak menumpuk/duplikat.
    Object? existingKey;
    if (item.orderNumber.isNotEmpty) {
      for (final key in _box.keys) {
        final value = _box.get(key);
        if (value != null && value.orderNumber == item.orderNumber) {
          existingKey = key;
          break;
        }
      }
    }

    // Tentukan key yang dipakai: item.id kalau valid (>0),
    // kalau tidak pakai id lokal berikutnya.
    final int keyToUse = item.id > 0 ? item.id : _nextId();

    if (existingKey != null) {
      // Kalau data yang sama sudah tersimpan di key lama yang beda,
      // hapus key lama supaya tidak ada duplikat, lalu simpan di keyToUse.
      if (existingKey != keyToUse) {
        await _box.delete(existingKey);
      }
      await _box.put(keyToUse, OrderHive.fromEntity(item, id: keyToUse));
    } else {
      await _box.put(keyToUse, OrderHive.fromEntity(item, id: keyToUse));
    }
  }

  Future<void> reset() async {
    await _box.clear();
  }
}
