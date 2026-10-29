import 'package:flutter/material.dart';
import '../../../../core/themes/restaurant_colors.dart';
import '../../domain/entities/table.dart';

class TableCard extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback? onClear;
  final VoidCallback? onTakeOrder;

  const TableCard({
    super.key,
    required this.table,
    this.onClear,
    this.onTakeOrder,
  });

  @override
  Widget build(BuildContext context) {
    final occupied = table.status == TableStatus.terisi;
    final color = occupied
        ? RestaurantColors.warning
        : RestaurantColors.success;
    final bg = occupied
        ? RestaurantColors.warningBg
        : RestaurantColors.successBg;

    return Container(
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
                'Meja ${table.number}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: RestaurantColors.textPrimary,
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              table.status.label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          if (occupied) ...[
            const SizedBox(height: 8),
            Text(
              '${table.guestCount ?? '-'} tamu · ${table.orderNumber ?? '-'}',
              style: const TextStyle(
                fontSize: 11.5,
                color: RestaurantColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (onTakeOrder != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTakeOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: RestaurantColors.primaryBrown,
                  side: const BorderSide(color: RestaurantColors.primaryBrown),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Catat Pesanan'),
              ),
            ),
          if (occupied && onClear != null) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  foregroundColor: RestaurantColors.textPrimary,
                  side: const BorderSide(color: RestaurantColors.cardBorder),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 11.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Kosongkan'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
