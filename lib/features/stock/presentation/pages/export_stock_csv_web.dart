// Web implementation of Stock CSV export
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:restauran_menu/shared/utils/date_time_formatter.dart';

import '../../domain/entities/stock_item.dart';
import '../provider/category_provider.dart';
import '../provider/unit_provider.dart';

Future<void> exportStockCsv(
  BuildContext context,
  List<StockItem> items,
  CategoryProvider categoryProvider,
  UnitProvider unitProvider,
) async {
  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tidak ada data stok untuk diekspor')),
    );
    return;
  }
  final buffer = StringBuffer();
  buffer.writeln(
    'ID,SKU,Nama,Kategori,Satuan,Stok Saat Ini,Stok Minimum,Harga Modal,Supplier,Status,Tanggal Dibuat',
  );
  for (final item in items) {
    final catName = item.categoryId != null
        ? categoryProvider.getCategoriById(item.categoryId!)?.name ?? '-'
        : '-';
    final unitName = unitProvider.getUnitById(item.unitId)?.name ?? '-';
    final createdAt = item.createdAt != null
        ? formatDateTime(item.createdAt!.toLocal())
        : '-';
    final row = [
      item.id?.toString() ?? '-',
      item.sku ?? '-',
      item.name,
      catName,
      unitName,
      item.currentStock.toString(),
      item.minimumStock.toString(),
      item.costPrice?.toString() ?? '-',
      item.supplier ?? '-',
      item.isActive ? 'Aktif' : 'Non-aktif',
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
      'daftar_stok_${DateTime.now().millisecondsSinceEpoch}.csv',
    )
    ..click();
  html.Url.revokeObjectUrl(url);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('CSV berhasil diunduh')));
}
