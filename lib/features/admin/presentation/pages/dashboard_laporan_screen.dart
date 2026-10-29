import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/themes/app_colors.dart';
import 'package:restauran_menu/features/admin/presentation/provider/admin_provider.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../widgets/report_date_filter.dart';
import '../widgets/sales_report.dart';

class DashboardLaporanScreen extends StatelessWidget {
  const DashboardLaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<AdminProvider>(),
      child: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().load();
    });
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Pilih tanggal';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? _endDate ?? now)
        : (_endDate ?? _startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: isStart ? 'Tanggal mulai' : 'Tanggal akhir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked == null) return;
    setState(() {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      if (isStart) {
        _startDate = normalized;
        // Jaga konsistensi: mulai tidak boleh lewat akhir.
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = normalized;
        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
          _startDate = _endDate;
        }
      }
    });
  }

  void _applyFilter() {
    final messenger = ScaffoldMessenger.of(context);
    if (_startDate == null && _endDate == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai/akhir dulu')),
      );
      return;
    }
    // Kirim endDate inklusif seharian penuh ke API via query start_date/end_date.
    context.read<AdminProvider>().load(
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _resetFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    context.read<AdminProvider>().load();
  }

  // void _logout() {
  //   context.read<AuthProvider>().logOut();
  //   NavigationService.navigateAndRemove(NameRoute.login);
  // }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final dashboard = context.watch<AdminProvider>();
    return Container(
      color: RestaurantColors.background,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text(
                'Halo, ${user.name.split(' ').first}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              Text(
                user.roleLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // if (dashboard.tenant != null && !dashboard.tenant!.isActive)
            //   InactiveTenantBanner(
            //     canResend: user?.canManage ?? false,
            //     onResend: () => _resendVerification(user!.email),
            //   ),
            const Text(
              'Laporan Penjualan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: RestaurantColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ringkasan dari seluruh transaksi yang sudah selesai dibayar',
              style: TextStyle(color: RestaurantColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ReportDateFilter(
              startLabel: _fmt(_startDate),
              endLabel: _fmt(_endDate),
              isLoading: dashboard.status == DashboardStatus.loading,
              hasFilter: _startDate != null || _endDate != null,
              onPickStart: () => _pickDate(isStart: true),
              onPickEnd: () => _pickDate(isStart: false),
              onApply: _applyFilter,
              onReset: _resetFilter,
            ),
            if (dashboard.hasDateFilter) ...[
              const SizedBox(height: 12),
              Text(
                'Menampilkan ${_fmt(dashboard.startDateFilter)} – ${_fmt(dashboard.endDateFilter)}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: RestaurantColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (dashboard.status == DashboardStatus.loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
            // if (dashboard.status == DashboardStatus.error &&
            //     dashboard.errorMessage != null)
            //   Container(
            //     width: double.infinity,
            //     margin: const EdgeInsets.only(bottom: 16),
            //     padding: const EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: RestaurantColors.danger.withValues(alpha: 0.08),
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(
            //         color: RestaurantColors.danger.withValues(alpha: 0.3),
            //       ),
            //     ),
            //     child: Text(
            //       dashboard.errorMessage!,
            //       style: const TextStyle(
            //         fontSize: 12.5,
            //         color: RestaurantColors.danger,
            //       ),
            //     ),
            //   ),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _StatCard(
                  icon: Icons.payments_rounded,
                  label: 'Total Pendapatan',
                  value: formatRupiah(dashboard.sales.totalRevenue),
                  color: RestaurantColors.success,
                ),
                _StatCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Jumlah Transaksi',
                  value: '${dashboard.sales.transactionCount}',
                  color: RestaurantColors.info,
                ),
                _StatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Rata-rata / Transaksi',
                  value: formatRupiah(dashboard.sales.averagePerTransaction),
                  color: RestaurantColors.accentOrange,
                ),

                // _StatCard(
                //   icon: Icons.payments_rounded,
                //   label: 'Pesanan Hari Ini',
                //   value: formatRupiah(dashboard.revenueToday),
                //   color: RestaurantColors.success,
                // ),
                // _StatCard(
                //   icon: Icons.receipt_long_rounded,
                //   label: 'Pendapatan Hari Ini',
                //   value: '${dashboard.ordersToday}',
                //   color: RestaurantColors.info,
                // ),
                // _StatCard(
                //   icon: Icons.timelapse_rounded,
                //   label: 'Menunggu Diproses',
                //   value: '${dashboard.pendingTodayCount}',
                //   color: RestaurantColors.warning,
                // ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Berdasarkan Metode Pembayaran',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: RestaurantColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            PaymentMethodBreakdown(report: dashboard.sales),
            const SizedBox(height: 28),
            // const Text(
            //   'Menu Terlaris',
            //   style: TextStyle(
            //     fontSize: 15,
            //     fontWeight: FontWeight.bold,
            //     color: RestaurantColors.textPrimary,
            //   ),
            // ),
            // const SizedBox(height: 12),
            // //_TopMenuList(report: report),
            // const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: RestaurantColors.textPrimary,
            ),
          ),

          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: RestaurantColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodBreakdown extends StatelessWidget {
  final SalesReport report;
  const PaymentMethodBreakdown({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final maxTotal = [
      report.qrisTotal,
      report.cashTotal,
      report.transferTotal,
    ].fold<double>(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Column(
        children: [
          _PaymentMethodRow(
            icon: Icons.qr_code_2_rounded,
            label: 'QRIS',
            count: report.qrisCount,
            total: report.qrisTotal,
            maxTotal: maxTotal,
            color: RestaurantColors.accentOrange,
          ),
          const SizedBox(height: 14),
          _PaymentMethodRow(
            icon: Icons.payments_rounded,
            label: 'Cash',
            count: report.cashCount,
            total: report.cashTotal,
            maxTotal: maxTotal,
            color: RestaurantColors.primaryBrown,
          ),
          const SizedBox(height: 14),
          _PaymentMethodRow(
            icon: Icons.payments_rounded,
            label: 'Transfer',
            count: report.transferCount,
            total: report.transferTotal,
            maxTotal: maxTotal,
            color: RestaurantColors.accentblueLight,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final double total;
  final double maxTotal;
  final Color color;

  const _PaymentMethodRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.total,
    required this.maxTotal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxTotal == 0 ? 0.0 : total / maxTotal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              '$label · $count transaksi',
              style: const TextStyle(
                fontSize: 13,
                color: RestaurantColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              formatRupiah(total),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: RestaurantColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: RestaurantColors.background,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// class _TopMenuList extends StatelessWidget {
//   final _SalesReport report;
//   const _TopMenuList({required this.report});

//   @override
//   Widget build(BuildContext context) {
//     if (report.topMenuItems.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: RestaurantColors.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: RestaurantColors.cardBorder),
//         ),
//         child: const Text(
//           'Belum ada data penjualan menu.',
//           style: TextStyle(color: RestaurantColors.textSecondary),
//         ),
//       );
//     }

//     final maxQty = report.topMenuItems.first.value;

//     return Container(
//       decoration: BoxDecoration(
//         color: RestaurantColors.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: RestaurantColors.cardBorder),
//       ),
//       child: Column(
//         children: List.generate(report.topMenuItems.length, (index) {
//           final entry = report.topMenuItems[index];
//           final isLast = index == report.topMenuItems.length - 1;
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//             decoration: BoxDecoration(
//               border: isLast
//                   ? null
//                   : const Border(
//                       bottom: BorderSide(color: RestaurantColors.cardBorder),
//                     ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 26,
//                   height: 26,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: RestaurantColors.accentOrange.withValues(
//                       alpha: 0.12,
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Text(
//                     '${index + 1}',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: RestaurantColors.accentOrange,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         entry.key,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: RestaurantColors.textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: LinearProgressIndicator(
//                           value: maxQty == 0 ? 0 : entry.value / maxQty,
//                           minHeight: 6,
//                           backgroundColor: RestaurantColors.background,
//                           valueColor: const AlwaysStoppedAnimation(
//                             RestaurantColors.primaryBrown,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   '${entry.value} terjual',
//                   style: const TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w600,
//                     color: RestaurantColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
