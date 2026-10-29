import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../routes/name_route.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../provider/cart_provider.dart';

class CashPaymentScreen extends StatelessWidget {
  const CashPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.total;
    final orderNumber = cart.orderNumber;

    return Scaffold(
      backgroundColor: RestaurantColors.background,
      appBar: AppBar(
        backgroundColor: RestaurantColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: RestaurantColors.textPrimary),
        title: const Text(
          'Pembayaran Cash',
          style: TextStyle(color: RestaurantColors.textPrimary, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: RestaurantColors.accentOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  size: 42,
                  color: RestaurantColors.accentOrange,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Silakan bayar ke kasir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: RestaurantColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tunjukkan nomor pesanan ini kepada kasir\nuntuk menyelesaikan pembayaran.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: RestaurantColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // ── Order Number Box ──
              if (orderNumber != null && orderNumber.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: RestaurantColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: RestaurantColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Nomor Pesanan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: RestaurantColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        orderNumber,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: RestaurantColors.primaryBrown,
                        ),
                      ),
                      if ((cart.tableNumber != null &&
                              cart.tableNumber!.isNotEmpty) ||
                          (cart.customerName != null &&
                              cart.customerName!.isNotEmpty)) ...[
                        const Divider(
                          height: 20,
                          color: RestaurantColors.cardBorder,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (cart.tableNumber != null &&
                                cart.tableNumber!.isNotEmpty)
                              Text(
                                'Meja: ${cart.tableNumber}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: RestaurantColors.textSecondary,
                                ),
                              ),
                            if (cart.tableNumber != null &&
                                cart.tableNumber!.isNotEmpty &&
                                cart.customerName != null &&
                                cart.customerName!.isNotEmpty)
                              const Text(
                                '  •  ',
                                style: TextStyle(
                                  color: RestaurantColors.textMuted,
                                ),
                              ),
                            if (cart.customerName != null &&
                                cart.customerName!.isNotEmpty)
                              Text(
                                cart.customerName!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: RestaurantColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: RestaurantColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: RestaurantColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        color: RestaurantColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatRupiah(total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Order publik sudah dibuat via POST
                    // api/menu/:slug/order di PaymentMethodScreen.
                    if (!context.mounted) return;
                    await Navigator.pushNamedAndRemoveUntil(
                      context,
                      NameRoute.orderSuccess,
                      (route) => route.settings.name == NameRoute.customerHome,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RestaurantColors.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Pesanan Sudah Dibayar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  try {
                    final order = await sl<PublicMenuProvider>()
                        .cancelPublicOrder(orderNumber!);
                    if (order != null && context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
                child: const Text(
                  'Batalkan',
                  style: TextStyle(color: RestaurantColors.danger),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
