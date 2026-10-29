import 'package:flutter/material.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../orders/domain/entities/order_entity.dart';

/// Badge kecil untuk tipe pesanan: Dine In / Take Away / Delivery.
/// Styling disamakan dengan [OrderStatusBadge].
class OrderTypeBadge extends StatelessWidget {
  final String orderType;
  const OrderTypeBadge({super.key, required this.orderType});

  (Color, Color) get _colors {
    switch (orderType) {
      case OrderEntity.typeDineIn:
        return (RestaurantColors.primaryBrown, const Color(0xFFEDE6DC));
      case OrderEntity.typeTakeaway:
        return (RestaurantColors.accentOrange, RestaurantColors.warningBg);
      case OrderEntity.typeDelivery:
        return (RestaurantColors.info, const Color(0xFFEAF2FE));
      default:
        return (
          RestaurantColors.textSecondary,
          const Color(0xFFF1EDE8),
        );
    }
  }

  String get _label {
    switch (orderType) {
      case OrderEntity.typeDineIn:
        return 'Dine In';
      case OrderEntity.typeTakeaway:
        return 'Take Away';
      case OrderEntity.typeDelivery:
        return 'Delivery';
      default:
        return orderType;
    }
  }

  IconData get _icon {
    switch (orderType) {
      case OrderEntity.typeDineIn:
        return Icons.restaurant_outlined;
      case OrderEntity.typeTakeaway:
        return Icons.shopping_bag_outlined;
      case OrderEntity.typeDelivery:
        return Icons.delivery_dining_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
