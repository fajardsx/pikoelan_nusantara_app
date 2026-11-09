// Web implementation of Stock Movement CSV export
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';

import '../../domain/entities/stock_movement.dart';

Future<void> exportStockMovementCsv(
  BuildContext context,
  List<StockMovement> movements,
) async {
  if (movements.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tidak ada data pergerakan stok untuk diekspor'),
      ),
    );
    return;
  }
  final buffer = StringBuffer();
  buffer.writeln(
    'ID,Item,Tipe,Alasan,Jumlah,Biaya Satuan,No. Referensi,Catatan,Stok Sebelum,Stok Sesudah,Tanggal Pergerakan,Tanggal Dibuat',
  );
  for (final m in movements) {
    final movementDate = formatDateTime(m.movementDate.toLocal());
    final createdAt = m.createdAt != null
        ? formatDateTime(m.createdAt!.toLocal())
        : '-';
    final row = [
      m.id?.toString() ?? '-',
      m.stockItemName ?? 'Item #${m.stockItemId}',
      m.type.value,
      m.reason.value,
      m.quantity.toString(),
      m.unitCost?.toString() ?? '-',
      m.referenceNumber ?? '-',
      m.notes ?? '-',
      m.stockBefore?.toString() ?? '-',
      m.stockAfter?.toString() ?? '-',
      movementDate,
      createdAt,
    ];
    final escaped = row
        .map((e) {
          final s = e.replaceAll('"', '""');
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
      'pergerakan_stok_${DateTime.now().millisecondsSinceEpoch}.csv',
    )
    ..click();
  html.Url.revokeObjectUrl(url);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('CSV berhasil diunduh')));
}
