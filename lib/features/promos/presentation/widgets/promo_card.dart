import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/promos/domain/entities/promo_entity.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';
import 'package:restauran_menu/shared/utils/show_custom_snack_bar.dart';

class PromoCard extends StatelessWidget {
  final PromoEntity promo;
  final ValueChanged<bool> onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PromoCard({
    super.key,
    required this.promo,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  String get _discountLabel {
    if (promo.discountType.toLowerCase() == 'percentage') {
      return '${promo.discountValue.toStringAsFixed(promo.discountValue.truncateToDouble() == promo.discountValue ? 0 : 1)}% OFF';
    }
    return '${formatRupiah(promo.discountValue)} OFF';
  }

  Color get _tierColor {
    switch (promo.applicableTier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFF8A9BA8);
      case 'gold':
        return const Color(0xFFD4AF37);
      case 'platinum':
        return const Color(0xFF6C5CE7);
      case 'vip':
        return const Color(0xFFE84393);
      default:
        return RestaurantColors.textSecondary;
    }
  }

  String get _tierLabel {
    if (promo.applicableTier.toLowerCase() == 'all') {
      return 'Semua Member';
    }
    return 'Tier ${promo.applicableTier.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = promo.endDate != null &&
        DateTime.now().isAfter(promo.endDate!.add(const Duration(days: 1)));

    return Container(
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: promo.isActive && !isExpired
              ? RestaurantColors.cardBorder
              : const Color(0xFFE2E2E2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header ticket bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: promo.isActive && !isExpired
                    ? RestaurantColors.accentOrange.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.1),
                border: const Border(
                  bottom: BorderSide(color: RestaurantColors.cardBorder),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: promo.isActive && !isExpired
                          ? RestaurantColors.accentOrange
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _discountLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _tierColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _tierLabel,
                      style: TextStyle(
                        color: _tierColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: RestaurantColors.dangerBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Kedaluwarsa',
                        style: TextStyle(
                          color: RestaurantColors.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          promo.isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: promo.isActive
                                ? RestaurantColors.success
                                : RestaurantColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Transform.scale(
                          scale: 0.75,
                          child: Switch(
                            value: promo.isActive,
                            activeColor: RestaurantColors.success,
                            onChanged: onToggleStatus,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Content body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promo.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: RestaurantColors.textPrimary,
                              ),
                            ),
                            if (promo.description != null &&
                                promo.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                promo.description!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: RestaurantColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Voucher Code chip with copy action
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: promo.code));
                          showCustomSnackBar(
                            context,
                            'Kode "${promo.code}" disalin ke clipboard',
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3ECE5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFDCCFBE),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.confirmation_number_outlined,
                                size: 14,
                                color: RestaurantColors.primaryBrown,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                promo.code,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: RestaurantColors.primaryBrown,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.copy_rounded,
                                size: 12,
                                color: RestaurantColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Conditions row (Min Order, Max Discount, Kuota)
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    children: [
                      if (promo.minOrderAmount != null &&
                          promo.minOrderAmount! > 0)
                        _buildDetailChip(
                          Icons.shopping_bag_outlined,
                          'Min. ${formatRupiah(promo.minOrderAmount!)}',
                        ),
                      if (promo.maxDiscountAmount != null &&
                          promo.maxDiscountAmount! > 0)
                        _buildDetailChip(
                          Icons.savings_outlined,
                          'Maks. ${formatRupiah(promo.maxDiscountAmount!)}',
                        ),
                      _buildDetailChip(
                        Icons.people_outline_rounded,
                        promo.usageLimit != null
                            ? '${promo.usageCount} / ${promo.usageLimit} kuota'
                            : '${promo.usageCount}x dipakai',
                      ),
                      if (promo.startDate != null || promo.endDate != null)
                        _buildDetailChip(
                          Icons.calendar_today_outlined,
                          promo.endDate != null
                              ? 's/d ${formatDate(promo.endDate!)}'
                              : 'Mulai ${formatDate(promo.startDate!)}',
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: RestaurantColors.cardBorder),

            // Bottom action row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: RestaurantColors.primaryBrown,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Hapus'),
                    style: TextButton.styleFrom(
                      foregroundColor: RestaurantColors.danger,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: RestaurantColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: RestaurantColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

