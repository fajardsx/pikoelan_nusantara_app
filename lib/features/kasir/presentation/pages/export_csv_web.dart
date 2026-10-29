// Web implementation of CSV export
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';

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
  final bytes = utf8.encode(buffer.toString());
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute(
      'download',
      'riwayat_transaksi_${DateTime.now().millisecondsSinceEpoch}.csv',
    )
    ..click();
  html.Url.revokeObjectUrl(url);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('CSV berhasil diunduh')));
}
