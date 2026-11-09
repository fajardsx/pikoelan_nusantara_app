import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../provider/kasir_provider.dart';

class PaymentPanel extends StatefulWidget {
  const PaymentPanel({super.key});

  @override
  State<PaymentPanel> createState() => _PaymentPanelState();
}

class _PaymentPanelState extends State<PaymentPanel> {
  final _cashController = TextEditingController();

  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _redeemController = TextEditingController();
  String? _prevOrderNumber;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      color: RestaurantColors.background,
      child: Consumer<KasirProvider>(
        builder: (context, kasir, _) {
          // Clear cash field when selected order changes (replaces BlocConsumer listenWhen)
          if (kasir.selectedOrderNumber != _prevOrderNumber) {
            _prevOrderNumber = kasir.selectedOrderNumber;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _cashController.clear(),
            );
          }

          final order = kasir.selectedOrder;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Pembayaran',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: RestaurantColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (order == null)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Belum ada pesanan dipilih',
                      style: TextStyle(color: RestaurantColors.textSecondary),
                    ),
                  ),
                )
              else ...[
                Text(
                  order.isPaid == false
                      ? 'Metode Pembayaran'
                      : 'Pembayaran Lunas',
                  style: TextStyle(
                    fontSize: order.isPaid == false ? 12.5 : 17,
                    fontWeight: order.isPaid == false
                        ? FontWeight.normal
                        : FontWeight.bold,
                    color: order.isPaid == false
                        ? RestaurantColors.textSecondary
                        : RestaurantColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                if (!order.isPaid && order.paymentMethod == null)
                  Row(
                    children: [
                      Expanded(
                        child: _MethodButton(
                          label: 'QRIS',
                          icon: Icons.qr_code_2_rounded,
                          selected: kasir.paymentMethod == OrderEntity.payQris,
                          onTap: () => context
                              .read<KasirProvider>()
                              .setPaymentMethod(OrderEntity.payQris),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MethodButton(
                          label: 'Cash',
                          icon: Icons.payments_rounded,
                          selected: kasir.paymentMethod == OrderEntity.payCash,
                          onTap: () => context
                              .read<KasirProvider>()
                              .setPaymentMethod(OrderEntity.payCash),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                if (!order.isPaid && order.paymentMethod != null)
                  Column(
                    children: [
                      Text(
                        order.paymentLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: RestaurantColors.success,
                        ),
                      ),
                      if (kasir.paymentMethod == OrderEntity.payQrcode) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Scan QRIS di bawah',
                          style: TextStyle(
                            fontSize: 14,
                            color: RestaurantColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.asset('assets/images/qris.png', height: 150),
                      ],
                    ],
                  ),
                if (!order.isPaid)
                  Column(
                    children: [
                      if (kasir.paymentMethod == OrderEntity.payQrcode) ...[
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    getSaveSharedPref(
                                      key: SettingsKeys.restaurantQris,
                                    ),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.qr_code,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RestaurantColors.success,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                RestaurantColors.cardBorder,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 5.0,
                            children: [
                              Icon(
                                Icons.qr_code,
                                color: Colors.white,
                                size: 18,
                              ),
                              Text(
                                'Show QRIS',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 10),
                if (kasir.paymentMethod == OrderEntity.payCash) ...[
                  const Text(
                    'Dibayar',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: RestaurantColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: RestaurantColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RestaurantColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Rp',
                          style: TextStyle(
                            color: RestaurantColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _cashController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) {
                              final amount = int.tryParse(value) ?? 0;
                              context.read<KasirProvider>().setCashReceived(
                                amount,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kembalian',
                        style: TextStyle(color: RestaurantColors.textSecondary),
                      ),
                      Text(
                        formatRupiah(kasir.change),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: RestaurantColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (!order.isPaid)
                  Consumer<KasirProvider>(
                    builder: (context, kasirProvider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          if (kasirProvider.member == null) ...[
                            TextFormField(
                              controller: _memberController,
                              decoration: const InputDecoration(
                                labelText: 'Member',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Masukkan member ID / Phone'
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed:
                                  kasirProvider.status ==
                                      DashboardStatus.loading
                                  ? null
                                  : () async {
                                      try {
                                        final phone = _memberController.text
                                            .trim();
                                        await kasirProvider.validateMember(
                                          phone: phone,
                                        );
                                      } finally {}
                                    },
                              child: const Text('Validasi'),
                            ),
                          ],
                          if (kasirProvider.member != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Member valid\natas nama : ${kasirProvider.member!.name}\nTier : ${kasirProvider.member!.tier}\npoints : ${kasirProvider.member!.points} ',
                              style: const TextStyle(color: Colors.green),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _redeemController,
                              decoration: const InputDecoration(
                                labelText: 'Redeem Points',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed:
                                  kasirProvider.status ==
                                      DashboardStatus.loading
                                  ? null
                                  : () async {
                                      try {
                                        _memberController.text = "";
                                        await kasirProvider.resetMember();
                                      } finally {}
                                    },
                              child: const Text('Reset'),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                const Spacer(),
                if (!order.isPaid)
                  ElevatedButton(
                    onPressed: kasir.canProcessPayment
                        ? () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi Pembayaran'),
                                content: const Text(
                                  'Apakah pembayaran sudah selesai?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Tidak'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Ya'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await context
                                  .read<KasirProvider>()
                                  .processPayment();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pembayaran berhasil diproses'),
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RestaurantColors.success,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: RestaurantColors.cardBorder,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Konfirmasi Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                if (order.isPaid)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Review Print'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: [
                                        Text('Order: ${order.orderNumber}'),
                                        ...order.items.map(
                                          (item) => Text(
                                            '- ${item.itemName}, x${item.quantity}',
                                          ),
                                        ),
                                        Text(
                                          'Total: ${formatRupiah(order.total)}',
                                        ),
                                        Text('Metode: ${order.paymentLabel}'),
                                        // Add more details as needed
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Print'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await context
                                    .read<KasirProvider>()
                                    .printReceipt();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Mencetak struk...'),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RestaurantColors.primaryBrown,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  RestaurantColors.cardBorder,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Print Struk',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Review Print'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: [
                                        Text('Order: ${order.orderNumber}'),
                                        ...order.items.map(
                                          (item) => Text(
                                            '- ${item.itemName}, x${item.quantity}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Print'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await context
                                    .read<KasirProvider>()
                                    .printDapurReceipt();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Mencetak struk dapur...'),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RestaurantColors.primaryBrown,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  RestaurantColors.cardBorder,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Print Ke Dapur',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () async {
                          await context.read<KasirProvider>().processComplete();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Pesanan ${order.orderNumber} Selesai',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RestaurantColors.success,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: RestaurantColors.cardBorder,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Tandai Selesai',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 18),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MethodButton({
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? RestaurantColors.primaryBrown
              : RestaurantColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? RestaurantColors.primaryBrown
                : RestaurantColors.cardBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : RestaurantColors.primaryBrown,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
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
