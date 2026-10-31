import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/members/domain/entities/member_entity.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';
import 'package:restauran_menu/shared/utils/show_custom_snack_bar.dart';

class MemberDetailDialog extends StatelessWidget {
  final MemberEntity member;
  final VoidCallback onEdit;

  const MemberDetailDialog({
    super.key,
    required this.member,
    required this.onEdit,
  });

  static void show(
    BuildContext context, {
    required MemberEntity member,
    required VoidCallback onEdit,
  }) {
    showDialog(
      context: context,
      builder: (context) => MemberDetailDialog(member: member, onEdit: onEdit),
    );
  }

  LinearGradient get _cardGradient {
    switch (member.tier.toLowerCase()) {
      case 'bronze':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B4513), Color(0xFF5D2E0C)],
        );
      case 'silver':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A6268), Color(0xFF343A40)],
        );
      case 'gold':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4AF37), Color(0xFF8A7120)],
        );
      case 'platinum':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C5CE7), Color(0xFF3B2E99)],
        );
      default:
        return RestaurantColors.bannerGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kartu Member Digital',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: RestaurantColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Digital VIP Card View
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: _cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PIKOELAN NUSANTARA',
                          style: TextStyle(
                            color: Colors.white70,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            member.tier.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      member.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: member.memberCode),
                        );
                        showCustomSnackBar(
                          context,
                          'Kode Member disalin ke clipboard',
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            member.memberCode,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              letterSpacing: 1.5,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: Colors.white60,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SALDO POIN',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 9,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              '${member.points} PTS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'SEJAK',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 9,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              formatDate(member.joinDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Detail List
              _buildInfoRow(Icons.phone_rounded, 'Nomor Telepon', member.phone),
              if (member.email != null && member.email!.isNotEmpty)
                _buildInfoRow(Icons.email_outlined, 'Email', member.email!),
              if (member.birthDate != null)
                _buildInfoRow(
                  Icons.cake_outlined,
                  'Tanggal Lahir',
                  formatDate(member.birthDate!),
                ),
              if (member.address != null && member.address!.isNotEmpty)
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Alamat',
                  member.address!,
                ),
              _buildInfoRow(
                Icons.storefront_rounded,
                'Total Kunjungan',
                '${member.totalVisits} kali kunjungan',
              ),
              _buildInfoRow(
                Icons.payments_outlined,
                'Total Transaksi Belanja',
                formatRupiah(member.totalSpent),
              ),
              if (member.notes != null && member.notes!.isNotEmpty)
                _buildInfoRow(
                  Icons.note_alt_outlined,
                  'Catatan',
                  member.notes!,
                ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit Member'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      foregroundColor: RestaurantColors.primaryBrown,
                      side: const BorderSide(
                        color: RestaurantColors.cardBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RestaurantColors.accentOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: RestaurantColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: RestaurantColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
