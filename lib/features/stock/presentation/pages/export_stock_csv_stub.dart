import 'package:flutter/material.dart';

import '../../domain/entities/stock_item.dart';
import '../provider/category_provider.dart';
import '../provider/unit_provider.dart';

Future<void> exportStockCsv(
  BuildContext context,
  List<StockItem> items,
  CategoryProvider categoryProvider,
  UnitProvider unitProvider,
) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Export CSV not supported on this platform')),
  );
}
