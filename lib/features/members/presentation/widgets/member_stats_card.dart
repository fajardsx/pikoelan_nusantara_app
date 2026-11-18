import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/members/domain/entities/member_entity.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';

class MemberStatsCard extends StatelessWidget {
  final List<MemberEntity> members;

  const MemberStatsCard({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final total = members.length;
    final totalPoints = members.fold<int>(0, (sum, m) => sum + m.points);
    final totalSpent = members.fold<double>(
      0.0,
      (sum, m) => sum + m.totalSpent,
    );
    final totalVisits = members.fold<int>(0, (sum, m) => sum + m.totalVisits);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;
        final cards = [
          _buildItem(
            label: 'Total Member',
            value: '$total orang',
            icon: Icons.people_alt_rounded,
            iconColor: RestaurantColors.accentOrange,
            bgColor: RestaurantColors.warningBg,
          ),
          _buildItem(
            label: 'Poin Loyalitas',
            value: '$totalPoints pts',
            icon: Icons.stars_rounded,
            iconColor: const Color(0xFFD4AF37),
            bgColor: const Color(0xFFFEF9E7),
          ),
          _buildItem(
            label: 'Total Belanja Member',
            value: totalSpent > 0 ? formatRupiah(totalSpent) : 'Rp 0',
            icon: Icons.payments_rounded,
            iconColor: RestaurantColors.success,
            bgColor: RestaurantColors.successBg,
          ),
          _buildItem(
            label: 'Total Kunjungan',
            value: '$totalVisits kali',
            icon: Icons.storefront_rounded,
            iconColor: RestaurantColors.info,
            bgColor: const Color(0xFFEBF3FF),
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
              .map(
                (c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: c,
                  ),
                ),
              )
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
