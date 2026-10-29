import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../routes/name_route.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../provider/cart_provider.dart';

class QrisPaymentScreen extends StatefulWidget {
  const QrisPaymentScreen({super.key});

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  static const _durationSeconds = 5 * 60;
  int _secondsLeft = _durationSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

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
          'Pembayaran QRIS',
          style: TextStyle(color: RestaurantColors.textPrimary, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Scan QRIS untuk melakukan pembayaran',
                style: TextStyle(color: RestaurantColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: RestaurantColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: RestaurantColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      getSaveSharedPref(
                        key: SettingsKeys.restaurantName,
                        defaultValue: "",
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: RestaurantColors.textPrimary,
                      ),
                    ),
                    if (orderNumber != null && orderNumber.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: RestaurantColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: RestaurantColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.receipt_long_rounded,
                              size: 16,
                              color: RestaurantColors.primaryBrown,
                            ),
                            const SizedBox(width: 6),
                            SelectableText(
                              orderNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: RestaurantColors.primaryBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if ((cart.tableNumber != null &&
                            cart.tableNumber!.isNotEmpty) ||
                        (cart.customerName != null &&
                            cart.customerName!.isNotEmpty)) ...[
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (cart.tableNumber != null &&
                              cart.tableNumber!.isNotEmpty)
                            'Meja: ${cart.tableNumber}',
                          if (cart.customerName != null &&
                              cart.customerName!.isNotEmpty)
                            cart.customerName!,
                        ].join('  •  '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: RestaurantColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      width: 250,
                      height: 250,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: RestaurantColors.cardBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          getSaveSharedPref(key: SettingsKeys.restaurantQris),
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.qr_code,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: RestaurantColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sisa waktu: $_formattedTime',
                    style: const TextStyle(
                      color: RestaurantColors.warning,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
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
                    'Saya Sudah Bayar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final order = await sl<PublicMenuProvider>()
                        .cancelPublicOrder(orderNumber!);
                    if (order != null && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RestaurantColors.danger,
                    side: const BorderSide(color: RestaurantColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Batalkan'),
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
