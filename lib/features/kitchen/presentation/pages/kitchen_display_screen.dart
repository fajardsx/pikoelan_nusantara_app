import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/shared/utils/logout_helper.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/date_time_formatter.dart';
import '../../../notifications/presentation/widgets/order_stream_status_badge.dart';
import '../provider/kitchen_provider.dart';
import '../widgets/kitchen_column.dart';
import '../widgets/kitchen_order_card.dart';

class KitchenDisplayScreen extends StatefulWidget {
  const KitchenDisplayScreen({super.key});

  @override
  State<KitchenDisplayScreen> createState() => _KitchenDisplayScreenState();
}

class _KitchenDisplayScreenState extends State<KitchenDisplayScreen> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Refresh every 30s so the clock and each card's "elapsed" indicator
    // stay accurate without needing a manual refresh.
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _confirmExit() => confirmAndLogout(
    context,
    title: 'Keluar dari Kitchen Display?',
    message: 'Sesi login akan dihapus dan kamu kembali ke halaman login.',
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => sl<KitchenProvider>()..load(),
        ),
      ],
      child: Scaffold(
        backgroundColor: RestaurantColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(now: _now, onExit: _confirmExit),
              Expanded(
                child: Consumer<KitchenProvider>(
                  builder: (context, kitchen, _) {
                    bool useExpanded = isMobileView(context);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            KitchenColumn(
                              title: 'Baru',
                              accentColor: RestaurantColors.info,
                              orders: kitchen.baru,
                              onExpanded: useExpanded,
                              cardBuilder: (order) => KitchenOrderCard(
                                order: order,
                                actionLabel: 'Mulai Masak',
                                actionIcon: Icons.soup_kitchen_rounded,
                                actionColor: RestaurantColors.primaryBrown,
                                onAction: () => context
                                    .read<KitchenProvider>()
                                    .startCooking(order),
                              ),
                            ),
                            KitchenColumn(
                              title: 'Proses',
                              accentColor: RestaurantColors.warning,
                              orders: kitchen.proses,
                              onExpanded: useExpanded,
                              cardBuilder: (order) => KitchenOrderCard(
                                order: order,
                                actionLabel: 'Tandai Siap',
                                actionIcon: Icons.check_circle_rounded,
                                actionColor: RestaurantColors.warning,
                                onAction: () => context
                                    .read<KitchenProvider>()
                                    .markReady(order),
                              ),
                            ),
                            KitchenColumn(
                              title: 'Siap Diantar',
                              accentColor: RestaurantColors.success,
                              orders: kitchen.siap,
                              onExpanded: useExpanded,
                              cardBuilder: (order) => KitchenOrderCard(
                                order: order,
                                actionLabel: 'Sudah Diambil',
                                actionIcon: Icons.done_all_rounded,
                                actionColor: RestaurantColors.success,
                                onAction: () => context
                                    .read<KitchenProvider>()
                                    .markPickedUp(order),
                                // onAction:
                                //     order.orderType != OrderEntity.typeDineIn
                                //     ? () => context
                                //           .read<KitchenProvider>()
                                //           .markPickedUp(order)
                                //     : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final DateTime now;
  final VoidCallback onExit;
  const _TopBar({required this.now, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RestaurantColors.cardBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: RestaurantColors.primaryBrown,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.soup_kitchen_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kitchen Display',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: RestaurantColors.textPrimary,
                ),
              ),
              Text(
                getSaveSharedPref(
                  key: SettingsKeys.restaurantName,
                  defaultValue: "Nama Restaurant",
                ),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: RestaurantColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          const OrderStreamStatusBadge(),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: RestaurantColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: RestaurantColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: RestaurantColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  formatTime(now),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onExit,
            icon: const Icon(
              Icons.logout_rounded,
              color: RestaurantColors.textSecondary,
            ),
            tooltip: 'Keluar',
          ),
        ],
      ),
    );
  }
}
