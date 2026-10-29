import 'package:hive_ce/hive_ce.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_item_entity.dart';

import '../../../customers/domain/entities/cart_item.dart';
import 'order_item_hive.dart';

class OrderHive {
  OrderHive({
    required this.id,
    required this.orderNumber,
    this.tableNumber,
    required this.orderTypeIndex,
    required this.statusIndex,
    required this.items,
    this.source,
    required this.createdAt,
    this.paymentMethodIndex,
    this.isPaid = false,
    this.customerName,
    this.notes,
  });

  int id;
  String orderNumber;
  int? tableNumber;
  int orderTypeIndex;
  int statusIndex;
  String? source;
  List<OrderItemHive> items;
  DateTime createdAt;
  int? paymentMethodIndex;
  bool isPaid;
  String? customerName;
  String? notes;

  OrderEntity toEntity() {
    final orderType = OrderEntity.orderTypeFromLegacyIndex(orderTypeIndex);
    final status = OrderEntity.statusFromLegacyIndex(statusIndex);
    final payment = OrderEntity.paymentFromLegacyIndex(paymentMethodIndex);
    final entityItems = items
        .map(
          (i) => OrderItemEntity(
            id: id,
            menuItemId: int.tryParse(i.menuItemId),
            itemName: i.menuItemName,
            price: i.price.toDouble(),
            quantity: i.quantity,
            subtotal: i.price.toDouble() * i.quantity,
            notes: i.note,
          ),
        )
        .toList();
    final total = entityItems.fold(0.0, (s, e) => s + e.subtotal);
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      orderType: orderType,
      tableNumber: tableNumber?.toString(),
      customerName: customerName,
      status: status,
      source: source ?? 'staff',
      paymentMethod: payment,
      notes: notes,
      totalAmount: total,
      createdAt: createdAt,
      items: entityItems,
      isPaid: isPaid,
    );
  }

  static OrderHive fromEntity(OrderEntity entity, {required int id}) {
    final orderType = OrderEntity.indexOrderType(entity.orderType);
    final status = OrderEntity.indexStatus(entity.status);
    // Order aktif belum bayar -> paymentMethod null, jangan paksa `!`.
    final rawPayment = entity.paymentMethod;
    int? payment;
    if (rawPayment != null && rawPayment.isNotEmpty) {
      final i = OrderEntity.indexPaymentType(rawPayment);
      if (i >= 0) {
        payment = i;
      } else if (rawPayment == OrderEntity.payQrcode) {
        // Toleransi kode backend lama "qrcode" == qris.
        payment = OrderEntity.indexPaymentType(OrderEntity.payQris);
        if (payment < 0) payment = null;
      } else {
        payment = null;
      }
    }
    return OrderHive(
      id: id,
      orderNumber: entity.orderNumber,
      tableNumber: entity.tableNumberInt,
      orderTypeIndex: orderType < 0 ? 0 : orderType,
      statusIndex: status < 0 ? 0 : status,
      items: itemsFromEntity(entity.items),
      source: entity.source,
      createdAt: entity.createdAt,
      paymentMethodIndex: payment,
      isPaid: entity.isPaid,
      customerName: entity.customerName,
      notes: entity.notes,
    );
  }

  static List<OrderItemHive> itemsFromCart(List<CartItem> cartItems) {
    return cartItems
        .map(
          (c) => OrderItemHive(
            menuItemId: c.menuItem.id.toString(),
            menuItemName: c.menuItem.name,
            price: c.menuItem.price.round(),
            quantity: c.quantity,
            note: c.note,
          ),
        )
        .toList();
  }

  static List<OrderItemHive> itemsFromEntity(List<OrderItemEntity> items) {
    return items
        .map(
          (e) => OrderItemHive(
            menuItemId: (e.menuItemId ?? 0).toString(),
            menuItemName: e.itemName,
            price: e.price.round(),
            quantity: e.quantity,
            note: e.notes,
          ),
        )
        .toList();
  }
}

class OrderHiveAdapter extends TypeAdapter<OrderHive> {
  @override
  final int typeId = 2;

  @override
  OrderHive read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return OrderHive(
      id: fields[0] as int,
      orderNumber: fields[1] as String,
      tableNumber: fields[2] as int?,
      orderTypeIndex: fields[3] as int,
      statusIndex: fields[4] as int,
      items: (fields[5] as List).cast<OrderItemHive>(),
      createdAt: fields[6] as DateTime,
      paymentMethodIndex: fields[7] as int?,
      isPaid: fields[8] as bool? ?? false,
      customerName: fields[9] as String?,
      notes: fields[10] as String?,
      source: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderHive obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderNumber)
      ..writeByte(2)
      ..write(obj.tableNumber)
      ..writeByte(3)
      ..write(obj.orderTypeIndex)
      ..writeByte(4)
      ..write(obj.statusIndex)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.paymentMethodIndex)
      ..writeByte(8)
      ..write(obj.isPaid)
      ..writeByte(9)
      ..write(obj.customerName)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.source);
  }
}
