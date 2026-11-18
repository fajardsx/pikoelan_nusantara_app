import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';
import 'package:restauran_menu/web/html_stub.dart'
    if (dart.library.html) 'package:restauran_menu/web/html_real.dart'
    as html;

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../routes/name_route.dart';
import '../../../../shared/utils/show_custom_snack_bar.dart';
import '../provider/cart_provider.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  Future<void> _copyOrderNumber(
    BuildContext context,
    String orderNumber,
  ) async {
    await Clipboard.setData(ClipboardData(text: orderNumber));
    if (!context.mounted) return;
    showCustomSnackBar(context, 'Nomor pesanan berhasil disalin');
  }

  Future<void> _printInvoice(BuildContext context) async {
    if (kIsWeb) {
      final cart = context.read<CartProvider>();
      final orderNumber = cart.orderNumber ?? '';
      final font = await PdfGoogleFonts.notoSansRegular();
      // Load logo from assets (ensure assets/logo.png is declared in pubspec.yaml)
      final logoBytes = (await rootBundle.load(
        'assets/images/favicon.png',
      )).buffer.asUint8List();
      final logo = pw.MemoryImage(logoBytes);
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Image(logo, width: 120)),
              pw.SizedBox(height: 20),
              pw.Text('Invoice', style: pw.TextStyle(font: font, fontSize: 28)),
              pw.SizedBox(height: 12),
              pw.Text(
                'Nomor Pesanan: $orderNumber',
                style: pw.TextStyle(font: font, fontSize: 16),
              ),
              pw.Text(
                'Tanggal: ${DateTime.now().toLocal().toString().split('.').first}',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Nama Pelanggan: ${cart.customerName ?? '-'}',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.Text(
                'Meja: ${cart.tableNumber ?? '-'}',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.Text(
                'Alamat: ${cart.address ?? '-'}',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.Text(
                'Telepon: ${cart.phone ?? '-'}',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Detail Pesanan:',
                style: pw.TextStyle(font: font, fontSize: 18),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Harga', 'Subtotal'],
                data: cart.items
                    .map(
                      (e) => [
                        e.menuItem.name,
                        e.quantity.toString(),
                        (formatRupiah(e.menuItem.price)),
                        (formatRupiah(e.subtotal)),
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(font: font),
              ),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: ${formatRupiah(cart.total)}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      final bytes = await pdf.save();
      //if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'invoice_$orderNumber.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
      // } else {
      //   await Printing.layoutPdf(onLayout: (format) async => bytes);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderNumber = context.watch<CartProvider>().orderNumber;

    return Scaffold(
      backgroundColor: RestaurantColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: RestaurantColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: RestaurantColors.success,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pesanan Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: RestaurantColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Setelah Pembayaran dikonfirmasi\nPesanan kamu segera disiapkan oleh dapur.\nMohon tunggu sebentar ya!',
                textAlign: TextAlign.center,
                style: TextStyle(color: RestaurantColors.textSecondary),
              ),
              const SizedBox(height: 24),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SelectableText(
                              orderNumber,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: RestaurantColors.primaryBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () =>
                                _copyOrderNumber(context, orderNumber),
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            color: RestaurantColors.primaryBrown,
                            tooltip: 'Salin nomor pesanan',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      NameRoute.ordersHistory,
                      arguments: {
                        if (orderNumber != null && orderNumber.isNotEmpty)
                          'orderNumber': orderNumber,
                      },
                    );
                  },
                  icon: const Icon(Icons.receipt_long_rounded, size: 20),
                  label: const Text('Pantau Pesanan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RestaurantColors.primaryBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: RestaurantColors.primaryBrown,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _printInvoice(context),
                  icon: const Icon(Icons.print_rounded, size: 20),
                  label: const Text('Cetak Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RestaurantColors.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartProvider>().clear();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      NameRoute.customerHome,
                      (route) => false,
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
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
