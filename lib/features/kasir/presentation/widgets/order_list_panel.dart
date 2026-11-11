import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_take_order_screen.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/utils/date_time_formatter.dart';
import '../../../customers/presentation/widgets/order_status_badge.dart';
import '../../../customers/presentation/widgets/order_type_badge.dart';
import '../../../notifications/presentation/widgets/order_stream_status_badge.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../provider/kasir_provider.dart';

class OrderListPanel extends StatelessWidget {
  const OrderListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      color: RestaurantColors.background,
      child: Consumer<KasirProvider>(
        builder: (context, kasir, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 20, 18, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pesanan Aktif',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                    OrderStreamStatusBadge(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _FilterTabs(kasir: kasir),
              ),
              const SizedBox(height: 8),

              // Filter Tanggal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Text(
                      'Tanggal:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate:
                                kasir.startDateFilter ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            var startDateFilter = DateTime(
                              selected.year,
                              selected.month,
                              selected.day,
                            );
                            var endDateFilter = DateTime(
                              selected.year,
                              selected.month,
                              selected.day,
                              23,
                              59,
                              59,
                            );
                            await kasir.applyDate(
                              startDate: startDateFilter,
                              endDate: endDateFilter,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: RestaurantColors.surface,
                            border: Border.all(
                              color: RestaurantColors.cardBorder,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                kasir.startDateFilter != null
                                    ? formatDate(kasir.startDateFilter!)
                                    : formatDate(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: RestaurantColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: RestaurantColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (kasir.hasDateFilter) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        splashRadius: 16,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        onPressed: () async {
                          await kasir.applyDate(startDate: null, endDate: null);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: kasir.filteredOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada pesanan',
                          style: TextStyle(
                            color: RestaurantColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        itemCount: kasir.filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = kasir.filteredOrders[index];
                          final selected =
                              order.orderNumber == kasir.selectedOrderNumber;
                          return _OrderCard(
                            order: order,
                            selected: selected,
                            onTap: () =>
                                context.read<KasirProvider>().selectOrder(
                                  orderNumber: order.orderNumber,
                                  orderPaymentMethod: order.paymentMethod,
                                ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class OrderListPanelView extends StatefulWidget {
  const OrderListPanelView({super.key});

  @override
  State<OrderListPanelView> createState() => _OrderListPanelViewState();
}

class _OrderListPanelViewState extends State<OrderListPanelView> {
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<KasirProvider>().load();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: RestaurantColors.background,
      child: Consumer<KasirProvider>(
        builder: (context, kasir, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pesanan Aktif',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KasirTakeOrderScreen(),
                        ),
                      ),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: RestaurantColors.primaryBrown,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _FilterTabs(kasir: kasir),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: kasir.filteredOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada pesanan',
                          style: TextStyle(
                            color: RestaurantColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        itemCount: kasir.filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = kasir.filteredOrders[index];
                          final selected =
                              order.orderNumber == kasir.selectedOrderNumber;
                          return _OrderCard(
                            order: order,
                            selected: selected,
                            onTap: () =>
                                context.read<KasirProvider>().selectOrder(
                                  orderNumber: order.orderNumber,
                                  orderPaymentMethod: order.paymentMethod,
                                ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final KasirProvider kasir;
  const _FilterTabs({required this.kasir});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: OrderFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = OrderFilter.values[index];
          final isSelected = filter == kasir.filter;
          // Badge mengikuti daftar hari ini supaya konsisten dengan list.
          final today = kasir.filteredOrders;
          final count = filter == OrderFilter.semua
              ? today.length
              : today.where((o) => o.orderType == filter.orderType).length;
          return ChoiceChip(
            label: Text('${filter.label} $count'),
            selected: isSelected,
            onSelected: (_) => context.read<KasirProvider>().setFilter(filter),
            showCheckmark: false,
            selectedColor: RestaurantColors.primaryBrown,
            backgroundColor: RestaurantColors.surface,
            side: BorderSide(
              color: isSelected
                  ? RestaurantColors.primaryBrown
                  : RestaurantColors.cardBorder,
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : RestaurantColors.textPrimary,
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final bool selected;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: RestaurantColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? RestaurantColors.primaryBrown
                : RestaurantColors.cardBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: RestaurantColors.textPrimary,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.end,
                  children: [
                    OrderTypeBadge(orderType: order.orderType),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.itemCount} item${order.tableNumber != null && order.tableNumber!.isNotEmpty ? ' · Meja ${order.tableNumber}' : ''}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: RestaurantColors.textSecondary,
                  ),
                ),
                Text(
                  formatTime(order.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: RestaurantColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              formatRupiah(order.totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: RestaurantColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
