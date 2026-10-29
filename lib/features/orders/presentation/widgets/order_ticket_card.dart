import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../domain/entities/order_entity.dart';
import 'status_badge.dart';

class OrderTicketCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onAdvance;
  final VoidCallback? onCancel;

  const OrderTicketCard({super.key, required this.order, this.onAdvance, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // strip atas ala perforasi tiket
          Container(height: 6, color: AppColors.primaryDark),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                          Text('# ${order.orderNumber}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontFamily: 'monospace', fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            order.customerName != null
                                ? '${order.contextLabel} · ${order.customerName}'
                                : order.contextLabel,
                            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                          ),
                          if (order.isSelfService) ...[
                            const SizedBox(height: 4),
                            const _SelfServiceTag(),
                          ],
                        ],
                      ),
                    ),
                    StatusBadge(status: order.status, label: order.statusLabel),
                  ],
                ),

                const SizedBox(height: 10),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.line),
                      bottom: BorderSide(color: AppColors.line),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: order.items
                        .map((it) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text('${it.quantity}× ',
                                      style: const TextStyle(fontFamily: 'monospace', color: AppColors.inkSoft, fontSize: 12.5)),
                                  Expanded(child: Text(it.itemName, style: const TextStyle(fontSize: 13))),
                                  Text(formatRupiah(it.subtotal),
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    Text(formatRupiah(order.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace', fontSize: 14)),
                  ],
                ),

                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('"${order.notes}"',
                      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppColors.inkSoft)),
                ],

                if (onAdvance != null || onCancel != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (onAdvance != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onAdvance,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                            child: Text(order.nextStatusLabel ?? 'Lanjut'),
                          ),
                        ),
                      if (onAdvance != null && onCancel != null) const SizedBox(width: 8),
                      if (onCancel != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(color: AppColors.dangerSoft),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Batalkan'),
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
    );
  }
}

class _SelfServiceTag extends StatelessWidget {
  const _SelfServiceTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFDCEAF5), borderRadius: BorderRadius.circular(10)),
      child: const Text(
        'PESAN SENDIRI VIA QR',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF2E5F8A), letterSpacing: 0.3),
      ),
    );
  }
}
