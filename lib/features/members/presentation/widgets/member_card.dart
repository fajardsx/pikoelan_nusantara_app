import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/members/domain/entities/member_entity.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';
import 'package:restauran_menu/shared/utils/show_custom_snack_bar.dart';

class MemberCard extends StatelessWidget {
  final MemberEntity member;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _tierColor {
    switch (member.tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFF7F8C8D);
      case 'gold':
        return const Color(0xFFD4AF37);
      case 'platinum':
        return const Color(0xFF8E44AD);
      case 'vip':
        return const Color(0xFFE84393);
      default:
        return RestaurantColors.primaryBrown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.cardBorder),
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
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top strip with Tier badge and Member Code
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _tierColor.withValues(alpha: 0.08),
                  border: const Border(
                    bottom: BorderSide(color: RestaurantColors.cardBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _tierColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        member.tier.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: member.memberCode),
                        );
                        showCustomSnackBar(
                          context,
                          'Kode Member "${member.memberCode}" disalin',
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            member.memberCode,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: RestaurantColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.copy_rounded,
                            size: 11,
                            color: RestaurantColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9E7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            size: 13,
                            color: Color(0xFFD4AF37),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${member.points} pts',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Color(0xFFB7950B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Middle content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _tierColor.withValues(alpha: 0.15),
                      child: Text(
                        member.name.isNotEmpty
                            ? member.name[0].toUpperCase()
                            : 'M',
                        style: TextStyle(
                          color: _tierColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: RestaurantColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_android_rounded,
                                size: 13,
                                color: RestaurantColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                member.phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: RestaurantColors.textSecondary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          if (member.email != null &&
                              member.email!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 13,
                                  color: RestaurantColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    member.email!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: RestaurantColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Activity stats bar (Visits, Spent, Join Date)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: RestaurantColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Kunjungan', '${member.totalVisits}x'),
                    const SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        width: 1,
                        color: RestaurantColors.cardBorder,
                      ),
                    ),
                    _buildStatCol(
                      'Total Belanja',
                      formatRupiah(member.totalSpent),
                    ),
                    const SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        width: 1,
                        color: RestaurantColors.cardBorder,
                      ),
                    ),
                    _buildStatCol('Bergabung', formatDate(member.joinDate)),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: RestaurantColors.cardBorder),

              // Action buttons footer
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.badge_outlined, size: 16),
                      label: const Text('Detail Kartu'),
                      style: TextButton.styleFrom(
                        foregroundColor: RestaurantColors.textSecondary,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Edit Member',
                      color: RestaurantColors.primaryBrown,
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      tooltip: 'Hapus Member',
                      color: RestaurantColors.danger,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: RestaurantColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: RestaurantColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
