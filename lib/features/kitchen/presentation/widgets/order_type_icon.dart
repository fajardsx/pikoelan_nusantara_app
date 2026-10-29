import 'package:flutter/material.dart';
import '../../../orders/domain/entities/order_entity.dart';

IconData orderTypeIcon(String type) {
  switch (type) {
    case OrderEntity.typeDineIn:
      return Icons.table_restaurant_rounded;
    case OrderEntity.typeTakeaway:
      return Icons.shopping_bag_rounded;
    case OrderEntity.typeDelivery:
      return Icons.delivery_dining_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}

String orderTypeLabel(String type) {
  switch (type) {
    case OrderEntity.typeDineIn:
      return 'Dine In';
    case OrderEntity.typeTakeaway:
      return 'Take Away';
    case OrderEntity.typeDelivery:
      return 'Delivery';
    default:
      return type;
  }
}
