import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/promos/data/models/promo_stats_response.dart';
import 'package:restauran_menu/features/promos/domain/entities/promo_entity.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';

class PromoStatsCard extends StatelessWidget {
  final PromoStatsResponse? stats;
  final List<PromoEntity> promos;

  const PromoStatsCard({
    super.key,
    required this.stats,
    required this.promos,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalPromos ?? promos.length;
    final active = stats?.activePromos ?? promos.where((p) => p.isActive).length;
    final usages = stats?.totalUsages ??
        promos.fold<int>(0, (sum, p) => sum + p.usageCount);
    final discountGiven = stats?.totalDiscountGiven ?? 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;
        final cards = [
          _buildItem(
            label: 'Total Promo',
            value: '$total',
            icon: Icons.local_offer_rounded,
            iconColor: RestaurantColors.accentOrange,
            bgColor: RestaurantColors.warningBg,
          ),
          _buildItem(
            label: 'Promo Aktif',
            value: '$active',
            icon: Icons.check_circle_rounded,
            iconColor: RestaurantColors.success,
            bgColor: RestaurantColors.successBg,
          ),
          _buildItem(
            label: 'Total Terpakai',
            value: '$usages kali',
            icon: Icons.redeem_rounded,
            iconColor: RestaurantColors.info,
            bgColor: const Color(0xFFEBF3FF),
          ),
          _buildItem(
            label: 'Diskon Diberikan',
            value: discountGiven > 0 ? formatRupiah(discountGiven) : '-',
            icon: Icons.savings_rounded,
            iconColor: const Color(0xFF8E44AD),
            bgColor: const Color(0xFFF5EEF8),
          ),
        ];

        if (isCompact) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: cards,
          );
        }

        return Row(
          children: cards
              .map((c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: c,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RestaurantColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: RestaurantColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: RestaurantColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

