import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/services/app_log.dart';
import 'package:restauran_menu/core/services/shared_pref_services.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';

class KasirPrint {
  /// Print receipt using a Bluetooth thermal printer (ESC/POS).
  Future<void> printReceipt(OrderEntity? selectedOrder) async {
    final order = selectedOrder;

    try {
      // Bluetooth MAC address of the printer (replace with your device)
      final prefs = SharedPrefServices.pref;
      final paperSize = prefs.getString(SettingsKeys.paperSize) ?? '58';
      String printerMac = prefs.getString(SettingsKeys.printerMac) ?? '';

      // Connect
      bool conexStatus = await PrintBluetoothThermal.connectionStatus;
      if (!conexStatus) {
        final result = await PrintBluetoothThermal.connect(
          macPrinterAddress: printerMac,
        );
        if (!result) {
          throw Exception('Failed to connect: $result');
          return;
        }
      }
      List<int> bytes = [];
      // Build ticket with esc_pos_utils_plus
      final profile = await CapabilityProfile.load();
      final generator = Generator(
        paperSize == "58" ? PaperSize.mm58 : PaperSize.mm80,
        profile,
      );

      bytes += generator.reset();

      // final ByteData data = await rootBundle.load(
      //   'assets/images/printicon.png',
      // );
      // final Uint8List bytesImg = data.buffer.asUint8List();
      // img.Image? image = img.decodeImage(bytesImg);
      // final resizedImage = img.copyResize(
      //   image!,
      //   width: image.width ~/ 1.3,
      //   height: image.height ~/ 1.3,
      //   interpolation: img.Interpolation.nearest,
      // );
      // final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
      // bytes += bytesimg;
      //bytes += generator.feed(1);
      bytes += generator.text(
        prefs.getString(SettingsKeys.restaurantName) ?? '',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        prefs.getString(SettingsKeys.restaurantAddress) ?? '',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        prefs.getString(SettingsKeys.restaurantPhone) ?? '',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(1);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Date',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Cashier',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: order!.createdAt.toLocal().toString().split('.').first,
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: sl<AuthProvider>().user!.name,
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.feed(2);
      bytes += generator.row([
        PosColumn(
          text: 'No. Order',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Customer Name',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: order.orderNumber,
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: order.customerName ?? "",
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.feed(2);
      bytes += generator.hr();

      // Items (adjust fields as needed)
      for (var item in order.items) {
        final name = item.itemName;
        final qty = item.quantity;
        final price = item.price;
        bytes += generator.text(
          name,
          styles: const PosStyles(align: PosAlign.left),
        );
        bytes += generator.row([
          PosColumn(
            text: '$qty x',
            width: 2,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: formatRupiah(price),
            width: 5,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: formatRupiah(price * qty),
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.feed(2);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Total',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: formatRupiah(order.total),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.feed(1);
      bytes += generator.row([
        PosColumn(
          text: 'Methode Pembayaran',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: order.paymentLabel,
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // bytes += generator.text(
      //   'Pembayaran dengan :',
      //   styles: const PosStyles(align: PosAlign.left, bold: true),
      // );
      // bytes += generator.text(
      //   order.paymentLabel,
      //   styles: const PosStyles(align: PosAlign.left),
      // );
      bytes += generator.hr();
      bytes += generator.text(
        'Thank you for your order!',
        styles: const PosStyles(
          align: PosAlign.center,
          fontType: PosFontType.fontA,
        ),
      );
      bytes += generator.hr();
      bytes += generator.cut();

      // Send bytes to printer
      await PrintBluetoothThermal.writeBytes(bytes);
      //await PrintBluetoothThermal.disconnect;
    } catch (e, s) {
      // UI can catch & show error via snackbar if desired
      AppLog.instance.logError('Gagal koneksi ke printer: $e', e, s);
    }
  }

  Future<void> printDapurReceipt(OrderEntity? selectedOrder) async {
    final order = selectedOrder;

    try {
      // Bluetooth MAC address of the printer (replace with your device)
      final prefs = SharedPrefServices.pref;
      final paperSize = prefs.getString(SettingsKeys.paperSize) ?? '58';
      String printerMac = prefs.getString(SettingsKeys.printerMacDapur) ?? '';
      if (printerMac.isEmpty) {
        printerMac = prefs.getString(SettingsKeys.printerMac) ?? '';
      }

      // Connect
      bool conexStatus = await PrintBluetoothThermal.connectionStatus;
      if (!conexStatus) {
        final result = await PrintBluetoothThermal.connect(
          macPrinterAddress: printerMac,
        );
        if (!result) {
          throw Exception('Failed to connect: $result');
        }
      }
      List<int> bytes = [];
      // Build ticket with esc_pos_utils_plus
      final profile = await CapabilityProfile.load();
      final generator = Generator(
        paperSize == "58" ? PaperSize.mm58 : PaperSize.mm80,
        profile,
      );

      bytes += generator.reset();

      // final ByteData data = await rootBundle.load(
      //   'assets/images/printicon.png',
      // );
      // final Uint8List bytesImg = data.buffer.asUint8List();
      // img.Image? image = img.decodeImage(bytesImg);
      // final resizedImage = img.copyResize(
      //   image!,
      //   width: image.width ~/ 1.3,
      //   height: image.height ~/ 1.3,
      //   interpolation: img.Interpolation.nearest,
      // );
      // final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
      // bytes += bytesimg;
      //bytes += generator.feed(1);
      bytes += generator.text(
        prefs.getString(SettingsKeys.restaurantName) ?? '',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        'Dapur',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(1);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Date',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Cashier',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: order!.createdAt.toLocal().toString().split('.').first,
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: sl<AuthProvider>().user!.name,
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.feed(2);
      bytes += generator.row([
        PosColumn(
          text: 'No. Order',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Customer Name',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: order.orderNumber,
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: order.customerName ?? "",
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);

      bytes += generator.feed(2);
      bytes += generator.hr();

      // Items (adjust fields as needed)
      for (var item in order.items) {
        final name = item.itemName;
        final qty = item.quantity;
        //final price = item.price;
        // bytes += generator.text(
        //   name,
        //   styles: const PosStyles(align: PosAlign.left),
        // );
        bytes += generator.row([
          PosColumn(
            text: name,
            width: 10,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '$qty x',
            width: 2,
            styles: const PosStyles(align: PosAlign.left),
          ),
        ]);
      }
      bytes += generator.feed(2);
      bytes += generator.feed(2);
      bytes += generator.text(
        'Note :',
        styles: const PosStyles(align: PosAlign.left),
      );
      bytes += generator.text(
        order.notes ?? "-",
        styles: const PosStyles(align: PosAlign.left),
      );
      bytes += generator.hr();
      // bytes += generator.row([
      //   PosColumn(
      //     text: 'Total',
      //     width: 6,
      //     styles: const PosStyles(align: PosAlign.left),
      //   ),
      //   PosColumn(
      //     text: formatRupiah(order.total),
      //     width: 6,
      //     styles: const PosStyles(align: PosAlign.right),
      //   ),
      // ]);
      // bytes += generator.feed(1);
      // bytes += generator.row([
      //   PosColumn(
      //     text: 'Methode Pembayaran',
      //     width: 6,
      //     styles: const PosStyles(align: PosAlign.left),
      //   ),
      //   PosColumn(
      //     text: order.paymentLabel,
      //     width: 6,
      //     styles: const PosStyles(align: PosAlign.right),
      //   ),
      // ]);

      // bytes += generator.text(
      //   'Pembayaran dengan :',
      //   styles: const PosStyles(align: PosAlign.left, bold: true),
      // );
      // bytes += generator.text(
      //   order.paymentLabel,
      //   styles: const PosStyles(align: PosAlign.left),
      // );
      // bytes += generator.hr();
      // bytes += generator.text(
      //   'Thank you for your order!',
      //   styles: const PosStyles(
      //     align: PosAlign.center,
      //     fontType: PosFontType.fontA,
      //   ),
      // );
      bytes += generator.hr();
      bytes += generator.cut();

      // Send bytes to printer
      await PrintBluetoothThermal.writeBytes(bytes);
      //await PrintBluetoothThermal.disconnect;
    } catch (e, s) {
      // UI can catch & show error via snackbar if desired
      AppLog.instance.logError('Gagal koneksi ke printer: $e', e, s);
    }
  }

  Future<List<int>> testTicket({String optionprinttype = "58"}) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      optionprinttype == "58" ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );
    bytes += generator.reset();

    //final ByteData data = await rootBundle.load('assets/images/printicon.png');
    //final Uint8List bytesImg = data.buffer.asUint8List();
    //img.Image? image = img.decodeImage(bytesImg);

    // if (Platform.isIOS) {
    //   final resizedImage = img.copyResize(
    //     image!,
    //     width: image.width ~/ 1.3,
    //     height: image.height ~/ 1.3,
    //     interpolation: img.Interpolation.nearest,
    //   );
    //   //final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
    // }

    bytes += generator.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ',
    );
    // bytes += generator.text(
    //   'Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ',
    //   styles: const PosStyles(codeTable: 'CP1252'),
    // );
    // bytes += generator.text(
    //   'Special 2: blåbærgrød',
    //   styles: const PosStyles(codeTable: 'CP1252'),
    // );

    // bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
    // bytes += generator.text(
    //   'Reverse text',
    //   styles: const PosStyles(reverse: true),
    // );
    // bytes += generator.text(
    //   'Underlined text',
    //   styles: const PosStyles(underline: true),
    //   linesAfter: 1,
    // );
    // bytes += generator.text(
    //   'Align left',
    //   styles: const PosStyles(align: PosAlign.left),
    // );
    // bytes += generator.text(
    //   'Align center',
    //   styles: const PosStyles(align: PosAlign.center),
    // );
    // bytes += generator.text(
    //   'Align right',
    //   styles: const PosStyles(align: PosAlign.right),
    //   linesAfter: 1,
    // );

    // bytes += generator.row([
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: const PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col6',
    //     width: 6,
    //     styles: const PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: const PosStyles(align: PosAlign.center, underline: true),
    //   ),
    // ]);

    // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    // bytes += generator.barcode(Barcode.upcA(barData));
    // bytes += generator.qrcode('example.com');

    // bytes += generator.text(
    //   'Text size 50%',
    //   styles: const PosStyles(fontType: PosFontType.fontB),
    // );
    // bytes += generator.text(
    //   'Text size 100%',
    //   styles: const PosStyles(fontType: PosFontType.fontA),
    // );
    // bytes += generator.text(
    //   'Text size 200%',
    //   styles: const PosStyles(
    //     height: PosTextSize.size2,
    //     width: PosTextSize.size2,
    //   ),
    // );

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }
}
