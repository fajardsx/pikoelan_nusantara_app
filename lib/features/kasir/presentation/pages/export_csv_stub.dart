import 'package:flutter/material.dart';

import '../../../orders/domain/entities/order_entity.dart';

Future<void> exportCsv(BuildContext context, List<OrderEntity> history) async {
  // Stub implementation for unsupported platforms.
  // You may choose to show a message or simply do nothing.
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Export CSV not supported on this platform')),
  );
}
