import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../routes/name_route.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../provider/cart_provider.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  /// POST `api/menu/:slug/order` dari isi keranjang.
  Future<void> _checkout(
    BuildContext context,
    String method,
    String nextRoute,
  ) async {
    final cart = context.read<CartProvider>();
    final menu = context.read<PublicMenuProvider>();
    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keranjang masih kosong.')));
      return;
    }
    final order = await menu.submitCart(
      cartItems: cart.items,
      orderType: cart.orderType,
      tableNumber: cart.tableNumber,
      customerName: cart.customerName,
      paymentMethod: method,
      notes: cart.notes,
    );
    if (!context.mounted) return;
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(menu.orderError ?? 'Gagal membuat pesanan.')),
      );
      return;
    }
    cart.setPaymentMethod(method);
    cart.setOrderNumber(order.orderNumber);
    await Navigator.pushNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.total;
    final isOrdering = context.watch<PublicMenuProvider>().isOrdering;

    return Scaffold(
      backgroundColor: RestaurantColors.background,
      appBar: AppBar(
        backgroundColor: RestaurantColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: RestaurantColors.textPrimary),
        title: const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(color: RestaurantColors.textPrimary, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (cart.orderType != OrderEntity.typeDelivery &&
                            (cart.customerName != null &&
                                cart.customerName!.isNotEmpty) ||
                        (cart.tableNumber != null &&
                            cart.tableNumber!.isNotEmpty))
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: RestaurantColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: RestaurantColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_pin_circle_rounded,
                              color: RestaurantColors.accentOrange,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cart.customerName?.isNotEmpty == true
                                        ? cart.customerName!
                                        : 'Pelanggan',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: RestaurantColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cart.tableNumber?.isNotEmpty == true
                                        ? 'Meja: ${cart.tableNumber}'
                                        : 'Tanpa Meja',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: RestaurantColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (cart.orderType == OrderEntity.typeDelivery &&
                            (cart.customerName != null &&
                                cart.customerName!.isNotEmpty) ||
                        (cart.tableNumber != null &&
                            cart.tableNumber!.isNotEmpty))
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: RestaurantColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: RestaurantColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_pin_circle_rounded,
                              color: RestaurantColors.accentOrange,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cart.customerName?.isNotEmpty == true
                                        ? cart.customerName!
                                        : 'Pelanggan',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: RestaurantColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cart.address?.isNotEmpty == true
                                        ? 'Alamat : ${cart.address}'
                                        : 'Alamat',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: RestaurantColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cart.phone?.isNotEmpty == true
                                        ? 'No. Telepon : ${cart.phone}'
                                        : 'No. Telepon ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: RestaurantColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (cart.orderType != OrderEntity.typeDelivery)
                      _PaymentOption(
                        icon: Icons.qr_code_2_rounded,
                        title: 'QRIS',
                        subtitle: 'Bayar cepat & mudah scan QRIS',
                        onTap: () => _checkout(
                          context,
                          OrderEntity.payQris,
                          NameRoute.qrisPayment,
                        ),
                      ),
                    if (cart.orderType != OrderEntity.typeDelivery)
                      const SizedBox(height: 14),
                    if (cart.orderType != OrderEntity.typeDelivery)
                      _PaymentOption(
                        icon: Icons.payments_rounded,
                        title: 'Cash',
                        subtitle: 'Bayar dengan uang tunai ke kasir',
                        onTap: () => _checkout(
                          context,
                          OrderEntity.payCash,
                          NameRoute.cashPayment,
                        ),
                      ),
                    //if (cart.orderType == OrderEntity.typeDelivery)
                    _PaymentOption(
                      icon: Icons.payment,
                      title: 'Transfer',
                      subtitle: 'Bayar dengan Transfer ke rekening',
                      onTap: () => _checkout(
                        context,
                        OrderEntity.payTransfer,
                        NameRoute.transferPayment,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: RestaurantColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: RestaurantColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(color: RestaurantColors.textSecondary),
                    ),
                    Text(
                      formatRupiah(total),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOrdering)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RestaurantColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RestaurantColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: RestaurantColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: RestaurantColors.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: RestaurantColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: RestaurantColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: RestaurantColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
