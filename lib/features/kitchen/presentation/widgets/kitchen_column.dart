import 'package:flutter/material.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../orders/domain/entities/order_entity.dart';

class KitchenColumn extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<OrderEntity> orders;
  final Widget Function(OrderEntity order) cardBuilder;
  final bool onExpanded;

  const KitchenColumn({
    super.key,
    required this.title,
    required this.accentColor,
    required this.orders,
    required this.cardBuilder,
    this.onExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 300,
      decoration: BoxDecoration(
        color: RestaurantColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: RestaurantColors.cardBorder),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: RestaurantColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada pesanan',
                      style: TextStyle(
                        color: RestaurantColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: orders.length,
                    itemBuilder: (context, index) => cardBuilder(orders[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
