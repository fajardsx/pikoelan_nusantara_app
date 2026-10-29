import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int id;
  final int? menuItemId;
  final String itemName;
  final double price;
  final int quantity;
  final double subtotal;
  final String? notes;

  const OrderItemEntity({
    required this.id,
    this.menuItemId,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.notes,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
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

    final qty = toInt(json['quantity'] ?? json['qty'], 1);
    final price = toDouble(
      json['price'] ?? json['unitPrice'] ?? json['unit_price'],
    );
    final subtotalRaw = json['subtotal'] ?? json['total'] ?? json['amount'];
    return OrderItemEntity(
      id: toInt(json['id'] ?? json['orderItemId'] ?? json['order_item_id']),
      menuItemId:
          (json['menuItemId'] ??
                  json['menu_item_id'] ??
                  json['menuId'] ??
                  json['menu_id']) ==
              null
          ? null
          : toInt(
              json['menuItemId'] ??
                  json['menu_item_id'] ??
                  json['menuId'] ??
                  json['menu_id'],
            ),
      itemName:
          (json['itemName'] ??
                  json['item_name'] ??
                  json['name'] ??
                  json['menuName'] ??
                  '')
              .toString(),
      price: price,
      quantity: qty <= 0 ? 1 : qty,
      subtotal: subtotalRaw != null
          ? toDouble(subtotalRaw)
          : price * (qty <= 0 ? 1 : qty),
      notes: (json['notes'] ?? json['note'])?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    menuItemId,
    itemName,
    price,
    quantity,
    subtotal,
    notes,
  ];
}
