import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/utils/date_time_formatter.dart';
import '../../../customers/presentation/widgets/order_status_badge.dart';
import '../../../customers/presentation/widgets/order_type_badge.dart';
import '../provider/kasir_provider.dart';

class OrderDetailPanel extends StatelessWidget {
  const OrderDetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      color: RestaurantColors.surface,
      child: Consumer<KasirProvider>(
        builder: (context, kasir, _) {
          final order = kasir.selectedOrder;
          if (order == null) {
            return const Center(
              child: Text(
                'Pilih pesanan untuk melihat detail',
                textAlign: TextAlign.center,
                style: TextStyle(color: RestaurantColors.textSecondary),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Detail Pesanan ${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 4),
                child: Text(
                  '${order.tableNumber != null && order.tableNumber!.isNotEmpty ? 'Meja ${order.tableNumber}' : order.orderTypeLabel} · ${formatDateTime(order.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: RestaurantColors.textSecondary,
                  ),
                ),
              ),
              if (order.customerName != null &&
                  order.customerName!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: RestaurantColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.customerName!.trim(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (order.notes != null && order.notes!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: RestaurantColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: RestaurantColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.sticky_note_2_outlined,
                          size: 14,
                          color: RestaurantColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.notes!.trim(),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: RestaurantColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (order.notes == null || order.notes!.trim().isEmpty)
                const SizedBox(height: 12),
              const Divider(height: 1, color: RestaurantColors.cardBorder),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: order.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.itemName,
                            style: const TextStyle(
                              color: RestaurantColors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${item.quantity}x',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: RestaurantColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            formatRupiah(item.subtotal),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: RestaurantColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: RestaurantColors.cardBorder),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Total',
                      value: formatRupiah(order.subtotalAmount),
                    ),
                    const SizedBox(height: 6),
                    getEnablePPN()
                        ? _SummaryRow(
                            label: 'Pajak (${getPPN()}%)',
                            value: formatRupiah(
                              order.taxWithRate(getPPN(calculate: true)),
                            ),
                          )
                        : const SizedBox(),
                    const Divider(
                      height: 22,
                      color: RestaurantColors.cardBorder,
                    ),
                    _SummaryRow(
                      label: 'Total Pembayaran',
                      value: formatRupiah(
                        getEnablePPN()
                            ? order.totalWithRate(getPPN(calculate: true))
                            : order.subtotalAmount,
                      ),
                      emphasize: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context
                                .read<KasirProvider>()
                                .cancelOrder(order),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: RestaurantColors.danger,
                              side: const BorderSide(
                                color: RestaurantColors.danger,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batalkan Pesanan'),
                          ),
                        ),
                        // const SizedBox(width: 10),
                        // Expanded(
                        //   child: OutlinedButton(
                        //     onPressed: () {
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(
                        //           content: Text('Pesanan disimpan'),
                        //         ),
                        //       );
                        //     },
                        //     style: OutlinedButton.styleFrom(
                        //       foregroundColor: RestaurantColors.textPrimary,
                        //       side: const BorderSide(
                        //         color: RestaurantColors.cardBorder,
                        //       ),
                        //       padding: const EdgeInsets.symmetric(vertical: 13),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //     child: const Text('Simpan'),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: emphasize ? 15.5 : 13.5,
            fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
            color: emphasize
                ? RestaurantColors.textPrimary
                : RestaurantColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 17 : 13.5,
            fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
            color: RestaurantColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
