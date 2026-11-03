import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'order_item_entity.dart';

class OrderEntity extends Equatable {
  /// Canonical order model used across the whole app (API + local Hive).
  ///
  /// Status codes: 'new' | 'proses' | 'ready' | 'deliver' |
  /// 'completed' | 'cancelled'.
  /// Order type codes: 'dine_in' | 'takeaway' | 'delivery'.
  /// Payment codes: 'qris' | 'cash' | null (null = not paid yet).
  static const statusNew = 'new';
  static const statusPreparing = 'preparing';
  static const statusProses = 'proses';
  static const statusReady = 'ready';
  static const statusDeliver = 'deliver';
  static const statusCompleted = 'completed';
  static const statusCancelled = 'cancelled';

  static const typeDineIn = 'dine_in';
  static const typeTakeaway = 'takeaway';
  static const typeDelivery = 'delivery';

  static const payQris = 'qrcode';
  static const payQrcode = 'qrcode';
  static const payCash = 'cash';
  static const payTransfer = 'transfer';

  /// Mapping index enum lama -> kode string baru.
  static const List<String> legacyStatusByIndex = [
    statusNew,
    statusProses,
    statusReady,
    statusDeliver,
    statusCompleted,
    statusCancelled,
  ];

  static const List<String> legacyOrderTypeByIndex = [
    typeDineIn,
    typeTakeaway,
    typeDelivery,
  ];

  static const List<String> legacyPaymentByIndex = [payQris, payCash];

  static String statusFromLegacyIndex(int index) {
    if (index < 0 || index >= legacyStatusByIndex.length) return statusNew;
    return legacyStatusByIndex[index];
  }

  static int indexStatus(String label) {
    return legacyStatusByIndex.indexOf(label);
  }

  static String orderTypeFromLegacyIndex(int index) {
    if (index < 0 || index >= legacyOrderTypeByIndex.length) return typeDineIn;
    return legacyOrderTypeByIndex[index];
  }

  static int indexOrderType(String label) {
    return legacyOrderTypeByIndex.indexOf(label);
  }

  static String? paymentFromLegacyIndex(int? index) {
    if (index == null) return null;
    if (index < 0 || index >= legacyPaymentByIndex.length) return null;
    return legacyPaymentByIndex[index];
  }

  static int indexPaymentType(String label) {
    return legacyPaymentByIndex.indexOf(label);
  }

  final int id;
  final String orderNumber;
  final String orderType;
  final String? tableNumber;
  final String? customerName;
  final String status;
  final String source;
  final String? paymentMethod;
  final String? notes;
  final double totalAmount;
  final DateTime createdAt;
  final List<OrderItemEntity> items;
  final bool isPaid;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    this.tableNumber,
    this.customerName,
    required this.status,
    required this.source,
    required this.paymentMethod,
    this.notes,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
    this.isPaid = false,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    List itemsJson = const [];
    final rawItems = json['items'] ?? json['orderItems'] ?? json['order_items'];
    if (rawItems is List) {
      itemsJson = rawItems;
    }
    final payment =
        (json['paymentMethod'] ?? json['payment_method'] ?? json['payment'])
            as String?;
    final paymentConfirmation =
        (json['payment_confirmation'] ?? json['paymentConfirmation']) as bool?;
    int toInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    DateTime toDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) {
        debugPrint("from string date : $v");
        final parsed = DateTime.tryParse(v);
        if (parsed != null) return parsed.toUtc().add(const Duration(hours: 7));
      }
      return DateTime.now();
    }

    return OrderEntity(
      id: toInt(json['id'] ?? json['orderId'] ?? json['order_id']),
      orderNumber:
          (json['orderNumber'] ?? json['order_number'] ?? json['orderNo'] ?? '')
              .toString(),
      orderType: (json['orderType'] ?? json['order_type'] ?? typeDineIn)
          .toString(),
      tableNumber: (json['tableNumber'] ?? json['table_number'])?.toString(),
      customerName: (json['customerName'] ?? json['customer_name'])?.toString(),
      status: (json['status'] as String?) ?? statusNew,
      paymentMethod: payment,
      source: ((json['source'] ?? json['sources']) as String?) ?? 'customer',
      notes: (json['notes'] ?? json['note'])?.toString(),
      totalAmount: toDouble(
        json['totalAmount'] ?? json['total_amount'] ?? json['total'],
      ),
      createdAt: toDate(json['createdAt'] ?? json['created_at']),
      items: itemsJson
          .map(
            (i) =>
                OrderItemEntity.fromJson(Map<String, dynamic>.from(i as Map)),
          )
          .toList(),
      isPaid:
          (json['isPaid'] as bool?) ??
          (paymentConfirmation != null && paymentConfirmation),
    );
  }

  OrderEntity copyWith({
    int? id,
    String? orderNumber,
    String? orderType,
    String? Function()? tableNumber,
    String? Function()? customerName,
    String? status,
    String? source,
    String? Function()? paymentMethod,
    String? Function()? notes,
    double? totalAmount,
    DateTime? createdAt,
    List<OrderItemEntity>? items,
    bool? isPaid,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      orderType: orderType ?? this.orderType,
      tableNumber: tableNumber != null ? tableNumber() : this.tableNumber,
      customerName: customerName != null ? customerName() : this.customerName,
      status: status ?? this.status,
      source: source ?? this.source,
      paymentMethod: paymentMethod != null
          ? paymentMethod()
          : this.paymentMethod,
      notes: notes != null ? notes() : this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  int get itemCount => items.fold(0, (s, i) => s + i.quantity);
  double get subtotalAmount => items.fold(0.0, (s, i) => s + i.subtotal);
  double get total => totalAmount;
  double get subtotal => subtotalAmount;
  double taxWithRate(double rate) => subtotalAmount * rate;
  double totalWithRate(double rate) => subtotalAmount + taxWithRate(rate);
  int? get tableNumberInt => int.tryParse((tableNumber ?? '').trim());
  bool get isQris => paymentMethod == payQris || paymentMethod == payQrcode;
  bool get isCash => paymentMethod == payCash;
  bool get isTransfer => paymentMethod == payTransfer;
  bool get isDineIn => orderType == typeDineIn;
  bool get isTakeaway => orderType == typeTakeaway;
  bool get isDelivery => orderType == typeDelivery;
  bool get isActive => status != statusCompleted && status != statusCancelled;
  bool get isCompleted => status == statusCompleted;
  bool get isCancelled => status == statusCancelled;

  static const _statusLabels = {
    statusNew: 'Baru',
    statusProses: 'Diproses',
    statusReady: 'Siap',
    statusDeliver: 'Diantar',
    statusCompleted: 'Selesai',
    statusCancelled: 'Batal',
    'baru': 'Baru',
    'siap': 'Siap',
    'diantar': 'Diantar',
    'selesai': 'Selesai',
    'dibatalkan': 'Batal',
  };

  static const _nextStatus = {
    statusNew: statusProses,
    statusProses: statusReady,
    statusReady: statusDeliver,
    statusDeliver: statusCompleted,
  };

  static const _nextLabel = {
    statusNew: 'Mulai Proses',
    statusProses: 'Tandai Siap',
    statusReady: 'Kirim / Antar',
    statusDeliver: 'Selesaikan',
  };

  String get statusLabel => _statusLabels[status] ?? status;
  String? get nextStatus => _nextStatus[status];
  String? get nextStatusLabel => _nextLabel[status];
  bool get canCancel => status == statusNew || status == statusProses;
  bool get isSelfService => source == 'customer';

  static const _orderTypeLabels = {
    typeDineIn: 'Dine In',
    typeTakeaway: 'Take Away',
    typeDelivery: 'Delivery',
  };

  String get orderTypeLabel => _orderTypeLabels[orderType] ?? orderType;

  String get contextLabel {
    if (tableNumber != null && tableNumber!.isNotEmpty) {
      return 'Meja $tableNumber';
    }
    switch (orderType) {
      case typeTakeaway:
        return 'Bawa pulang';
      case typeDelivery:
        return 'Antar';
      default:
        return 'Makan di tempat';
    }
  }

  String get paymentLabel {
    if (isQris) return 'QRIS';
    if (isCash) return 'Cash';
    if (isTransfer) return 'Transfer';
    return paymentMethod ?? '-';
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    status,
    totalAmount,
    source,
    createdAt,
    items,
    isPaid,
    paymentMethod,
  ];
}
