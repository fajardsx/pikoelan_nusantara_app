import 'package:flutter/material.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../kitchen/presentation/widgets/order_type_icon.dart';
import '../../../orders/domain/entities/order_entity.dart';

class ReadyOrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onDeliver;

  const ReadyOrderCard({
    super.key,
    required this.order,
    required this.onDeliver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.successBg, width: 1.4),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: RestaurantColors.successBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: RestaurantColors.success,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: RestaurantColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      orderTypeIcon(order.orderType),
                      size: 13,
                      color: RestaurantColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.tableNumber != null && order.tableNumber!.isNotEmpty
                          ? 'Meja ${order.tableNumber} · ${order.itemCount} item'
                          : '${order.itemCount} item',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: RestaurantColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ElevatedButton.icon(
          //   onPressed: onDeliver,
          //   icon: const Icon(Icons.delivery_dining_rounded, size: 18),
          //   label: const Text('Antar ke Meja'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: RestaurantColors.primaryBrown,
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     textStyle: const TextStyle(
          //       fontSize: 12.5,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
