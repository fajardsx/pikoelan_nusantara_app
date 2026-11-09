// Mobile & Desktop implementation of Stock Movement CSV export
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';
import 'package:share_plus/share_plus.dart';

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
  final dirTemp = await getTemporaryDirectory();
  final filePath =
      '${dirTemp.path}/pergerakan_stok_${DateTime.now().millisecondsSinceEpoch}.csv';
  final file = File(filePath);
  await file.writeAsString(buffer.toString());
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: 'Pergerakan Stok'),
  );
}
