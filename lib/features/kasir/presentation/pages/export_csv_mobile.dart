// Mobile implementation of CSV export
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../orders/domain/entities/order_entity.dart';

Future<void> exportCsv(BuildContext context, List<OrderEntity> history) async {
  if (history.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tidak ada data untuk diekspor')),
    );
    return;
  }
  final buffer = StringBuffer();
  buffer.writeln('No. Pesanan,Tanggal,Waktu,Tipe,Metode,Total,Status');
  for (final o in history) {
    final date = formatDate(o.createdAt);
    final time = formatTime(o.createdAt);
    final row = [
      o.orderNumber,
      date,
      time,
      o.orderTypeLabel,
      o.isQris ? 'QRIS' : 'Cash',
      o.totalAmount.toString(),
      o.status,
    ];
    final escaped = row
        .map((e) {
          final s = e.toString().replaceAll('"', '""');
          return '"$s"';
        })
        .join(',');
    buffer.writeln(escaped);
  }
  final dirTemp = await getTemporaryDirectory();
  final filePath =
      '${dirTemp.path}/riwayat_transaksi_${DateTime.now().millisecondsSinceEpoch}.csv';
  final file = File(filePath);
  await file.writeAsString(buffer.toString());
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: "Riwayat Transaksi"),
  );
}
