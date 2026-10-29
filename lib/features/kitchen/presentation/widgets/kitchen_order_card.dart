import 'package:flutter/material.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../orders/domain/entities/order_entity.dart';
import 'order_type_icon.dart';

class KitchenOrderCard extends StatelessWidget {
  final OrderEntity order;
  final String actionLabel;
  final IconData actionIcon;
  final Color actionColor;
  final VoidCallback? onAction;

  const KitchenOrderCard({
    super.key,
    required this.order,
    required this.actionLabel,
    required this.actionIcon,
    required this.actionColor,
    required this.onAction,
  });

  int get _elapsedMinutes =>
      DateTime.now().toLocal().difference(order.createdAt).inMinutes;

  Color get _elapsedColor {
    final m = _elapsedMinutes;
    if (m >= 15) return RestaurantColors.danger;
    if (m >= 7) return RestaurantColors.warning;
    return RestaurantColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: RestaurantColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _elapsedColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: _elapsedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_elapsedMinutes menit',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _elapsedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                orderTypeIcon(order.orderType),
                size: 14,
                color: RestaurantColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.tableNumber != null && order.tableNumber!.isNotEmpty
                      ? '${orderTypeLabel(order.orderType)} · Meja ${order.tableNumber}'
                      : orderTypeLabel(order.orderType),
                  style: const TextStyle(
                    fontSize: 12,
                    color: RestaurantColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (order.customerName != null &&
              order.customerName!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: RestaurantColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.customerName!.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RestaurantColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: RestaurantColors.warningBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: RestaurantColors.warning.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 15,
                    color: RestaurantColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.notes!.trim(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: RestaurantColors.accentOrange.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: RestaurantColors.accentOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                        if (item.notes != null &&
                            item.notes!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '• ${item.notes!.trim()}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: RestaurantColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 17),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
