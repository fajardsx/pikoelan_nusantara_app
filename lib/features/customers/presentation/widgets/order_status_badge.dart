import 'package:flutter/material.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../orders/domain/entities/order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  const OrderStatusBadge({super.key, required this.status});

  (Color, Color) get _colors {
    switch (status) {
      case OrderEntity.statusNew:
      case 'baru':
        return (RestaurantColors.info, const Color(0xFFEAF2FE));
      case OrderEntity.statusPreparing:
        return (RestaurantColors.warning, RestaurantColors.warningBg);
      case OrderEntity.statusProses:
        return (RestaurantColors.warning, RestaurantColors.warningBg);
      case OrderEntity.statusReady:
      case 'siap':
        return (RestaurantColors.success, RestaurantColors.successBg);
      case OrderEntity.statusDeliver:
      case 'diantar':
        return (RestaurantColors.accentOrange, RestaurantColors.warningBg);
      case OrderEntity.statusCompleted:
      case 'selesai':
        return (RestaurantColors.success, RestaurantColors.successBg);
      case OrderEntity.statusCancelled:
      case 'dibatalkan':
      default:
        return (RestaurantColors.danger, RestaurantColors.dangerBg);
    }
  }

  String get _label {
    final labels = {
      OrderEntity.statusNew: 'Baru',
      OrderEntity.statusProses: 'Diproses',
      OrderEntity.statusPreparing: 'Disiapkan',
      OrderEntity.statusReady: 'Siap',
      OrderEntity.statusDeliver: 'Diantar',
      OrderEntity.statusCompleted: 'Selesai',
      OrderEntity.statusCancelled: 'Batal',
      'baru': 'Baru',
      'siap': 'Siap',
      'diantar': 'Diantar',
      'selesai': 'Selesai',
      'dibatalkan': 'Batal',
    };
    return labels[status] ?? status;
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
      child: Text(
        _label,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
