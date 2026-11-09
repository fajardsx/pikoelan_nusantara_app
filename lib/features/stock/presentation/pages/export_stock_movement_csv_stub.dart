import 'package:flutter/material.dart';

import '../../domain/entities/stock_movement.dart';

Future<void> exportStockMovementCsv(
  BuildContext context,
  List<StockMovement> movements,
) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Export CSV not supported on this platform')),
  );
}
