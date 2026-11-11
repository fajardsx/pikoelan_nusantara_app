import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/routes/name_route.dart';
import 'package:restauran_menu/routes/navigator.dart';
import 'package:restauran_menu/shared/utils/logout_helper.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../customers/presentation/widgets/order_status_badge.dart';
import '../../../notifications/presentation/widgets/order_stream_status_badge.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/table.dart';
import '../provider/waiter_provider.dart';
import '../widgets/ready_order_card.dart';
import '../widgets/table_card.dart';

class WaiterShellScreen extends StatefulWidget {
  const WaiterShellScreen({super.key});

  @override
  State<WaiterShellScreen> createState() => _WaiterShellScreenState();
}

class _WaiterShellScreenState extends State<WaiterShellScreen> {
  int _tabIndex = 0;
  @override
  void initState() {
    super.initState();
    sl<MenuProvider>().load();
  }

  void _openTakeOrder(int tableNumber) {
    NavigationService.navigateTo(
      NameRoute.waiterTakeOrderDashboard,
      arguments: {"tableNumber": tableNumber},
    );
  }

  void _openTakeawayOrder() {
    NavigationService.navigateTo(NameRoute.waiterTakeOrderDashboard);
  }

  Future<void> _confirmExit() => confirmAndLogout(
    context,
    title: 'Keluar dari mode Waiter?',
    message: 'Sesi login akan dihapus dan kamu kembali ke halaman login.',
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: sl<WaiterProvider>()..load(refresh: true),
        ),
      ],
      child: Scaffold(
        backgroundColor: RestaurantColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onExit: _confirmExit),
              _TabSelector(
                index: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
              Expanded(
                child: switch (_tabIndex) {
                  0 => const _ReadyOrdersTab(),
                  1 => _TableStatusTab(
                    onTakeOrder: (table) => _openTakeOrder(table),
                  ),
                  _ => _MyOrdersTab(onNewOrder: _openTakeawayOrder),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onExit;
  const _TopBar({required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: const BoxDecoration(
        color: RestaurantColors.surface,
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
              Icons.room_service_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Waiter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: RestaurantColors.textPrimary,
                ),
              ),
              Text(
                getSaveSharedPref(
                  key: SettingsKeys.restaurantName,
                  defaultValue: "MenuMaju",
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

class _TabSelector extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _TabSelector({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RestaurantColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Siap Diantar',
              icon: Icons.delivery_dining_rounded,
              selected: index == 0,
              onTap: () => onChanged(0),
            ),
          ),
          // const SizedBox(width: 10),
          // Expanded(
          //   child: _TabButton(
          //     label: 'Status Meja',
          //     icon: Icons.table_bar_rounded,
          //     selected: index == 1,
          //     onTap: () => onChanged(1),
          //   ),
          // ),
          const SizedBox(width: 10),
          Expanded(
            child: _TabButton(
              label: 'Pesanan Saya',
              icon: Icons.edit_note_rounded,
              selected: index == 2,
              onTap: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? RestaurantColors.primaryBrown
              : RestaurantColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? RestaurantColors.primaryBrown
                : RestaurantColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : RestaurantColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : RestaurantColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyOrdersTab extends StatefulWidget {
  const _ReadyOrdersTab();

  @override
  State<_ReadyOrdersTab> createState() => _ReadyOrdersTabState();
}

class _ReadyOrdersTabState extends State<_ReadyOrdersTab> {
  String? _selectedOrderNumber;

  @override
  Widget build(BuildContext context) {
    return Consumer<WaiterProvider>(
      builder: (context, waiter, _) {
        final orders = waiter.readyOrders;
        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 56,
                  color: RestaurantColors.textMuted,
                ),
                SizedBox(height: 12),
                Text(
                  'Belum ada pesanan yang siap diantar',
                  style: TextStyle(color: RestaurantColors.textSecondary),
                ),
              ],
            ),
          );
        }

        var selected = orders.first;
        final match = orders.where(
          (o) => o.orderNumber == _selectedOrderNumber,
        );
        if (match.isNotEmpty) {
          selected = match.first;
        } else {
          _selectedOrderNumber = selected.orderNumber;
        }
        final current = selected;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${orders.length} pesanan siap diantar',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: RestaurantColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final isSelected =
                              order.orderNumber == current.orderNumber;
                          return InkWell(
                            onTap: () => setState(
                              () => _selectedOrderNumber = order.orderNumber,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: isSelected
                                      ? RestaurantColors.primaryBrown
                                      : Colors.transparent,
                                  width: 1.6,
                                ),
                              ),
                              child: ReadyOrderCard(
                                order: order,
                                onDeliver: () =>
                                    sl<WaiterProvider>().deliverOrder(order),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: _ReadyOrderDetail(
                        key: ValueKey(current.orderNumber),
                        order: current,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReadyOrderDetail extends StatelessWidget {
  final OrderEntity order;
  const _ReadyOrderDetail({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: RestaurantColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestaurantColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                      Text(
                        order.tableNumber != null &&
                                order.tableNumber!.isNotEmpty
                            ? 'Meja ${order.tableNumber} - ${order.orderTypeLabel}'
                            : order.orderTypeLabel,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: RestaurantColors.textSecondary,
                        ),
                      ),
                      if (order.customerName != null &&
                          order.customerName!.isNotEmpty)
                        Text(
                          "Nama : ${order.customerName}",
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: RestaurantColors.textSecondary,
                          ),
                        ),
                      if (order.notes != null && order.notes!.isNotEmpty)
                        Text(
                          "Catatan : ${order.notes}",
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: RestaurantColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 24),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Detail Pesanan (${order.items.length} menu)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: RestaurantColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: order.items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada item.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: order.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 16),
                    itemBuilder: (context, i) {
                      final item = order.items[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: RestaurantColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${item.quantity}x'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item.itemName)),
                          Text(formatCurrency(item.subtotal.toInt())),
                        ],
                      );
                    },
                  ),
          ),
          _ReadyDetailFooter(order: order),
        ],
      ),
    );
  }
}

class _ReadyDetailFooter extends StatelessWidget {
  final OrderEntity order;
  const _ReadyDetailFooter({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: RestaurantColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${order.itemCount} item'),
              Text(formatCurrency(order.totalAmount.toInt())),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => sl<WaiterProvider>().deliverOrder(order),
            icon: const Icon(Icons.delivery_dining_rounded, size: 18),
            label: const Text('Antar Pesanan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: RestaurantColors.primaryBrown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableStatusTab extends StatelessWidget {
  final ValueChanged<int> onTakeOrder;
  const _TableStatusTab({required this.onTakeOrder});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaiterProvider>(
      builder: (context, waiter, _) {
        bool useExpanded = isMobileView(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                '${waiter.occupiedCount} meja terisi · ${waiter.availableCount} meja kosong',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: RestaurantColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: useExpanded ? 4 : 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: waiter.tables.length,
                itemBuilder: (context, index) {
                  final table = waiter.tables[index];
                  return TableCard(
                    table: table,
                    onTakeOrder: () => onTakeOrder(table.number),
                    onClear: table.status == TableStatus.terisi
                        ? () => sl<WaiterProvider>().clearTable(table.number)
                        : null,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MyOrdersTab extends StatelessWidget {
  final VoidCallback onNewOrder;
  const _MyOrdersTab({required this.onNewOrder});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaiterProvider>(
      builder: (context, waiter, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(child: Text('${waiter.myOrders.length} pesanan')),
                  ElevatedButton.icon(
                    onPressed: onNewOrder,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Buat Pesanan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RestaurantColors.primaryBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _MyOrdersContent(onCreate: onNewOrder)),
          ],
        );
      },
    );
  }
}

class _MyOrdersContent extends StatelessWidget {
  final VoidCallback onCreate;
  const _MyOrdersContent({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaiterProvider>(
      builder: (context, waiter, _) {
        if (waiter.myOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 56,
                  color: RestaurantColors.textMuted,
                ),
                SizedBox(height: 12),
                Text(
                  'Belum ada pesanan yang kamu catat',
                  style: TextStyle(color: RestaurantColors.textSecondary),
                ),
                SizedBox(height: 12),
                // ElevatedButton.icon(
                //   onPressed: onCreate,
                //   icon: const Icon(Icons.add_rounded, size: 18),
                //   label: const Text('Buat Pesanan Baru'),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: RestaurantColors.primaryBrown,
                //     foregroundColor: Colors.white,
                //   ),
                // ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: waiter.myOrders.length,
          itemBuilder: (context, index) {
            final order = waiter.myOrders[index];
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
                        order.tableNumber != null &&
                                order.tableNumber!.isNotEmpty
                            ? '${order.orderNumber} · Meja ${order.tableNumber}'
                            : '${order.orderNumber} · ${order.orderTypeLabel}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.items
                        .map((i) => '${i.quantity}x ${i.itemName}')
                        .join(', '),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: RestaurantColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
