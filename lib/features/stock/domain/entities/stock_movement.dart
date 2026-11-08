import 'package:restauran_menu/core/common/common_utils.dart';

enum StockMovementType {
  stockIn('in'),
  stockOut('out'),
  adjustment('adjustment');

  final String value;
  const StockMovementType(this.value);

  static StockMovementType fromString(String val) {
    return StockMovementType.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => StockMovementType.adjustment,
    );
  }
}

enum StockMovementReason {
  purchase('purchase'),
  production('production'),
  waste('waste'),
  stockReturn('return'),
  transfer('transfer'),
  adjustment('adjustment'),
  initial('initial');

  final String value;
  const StockMovementReason(this.value);

  static StockMovementReason fromString(String val) {
    return StockMovementReason.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => StockMovementReason.adjustment,
    );
  }
}

class StockMovement {
  final int? id;
  final int stockItemId;
  final String? stockItemName;
  final StockMovementType type;
  final StockMovementReason reason;
  final double quantity;
  final double? unitCost;
  final String? referenceNumber;
  final String? notes;
  final DateTime movementDate;
  final DateTime? createdAt;

  StockMovement({
    this.id,
    required this.stockItemId,
    this.stockItemName,
    required this.type,
    required this.reason,
    required this.quantity,
    this.unitCost,
    this.referenceNumber,
    this.notes,
    required this.movementDate,
    this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as int?,
      stockItemId: json['stockItemId'] as int? ?? json['stock_item_id'] as int? ?? 0,
      stockItemName: json['stockItem'] != null && json['stockItem']['name'] != null
          ? json['stockItem']['name'] as String
          : json['stockItemName'] as String?,
      type: StockMovementType.fromString(json['type'] as String? ?? 'adjustment'),
      reason: StockMovementReason.fromString(json['reason'] as String? ?? 'adjustment'),
      quantity: toDouble(json['quantity']),
      unitCost: json['unitCost'] != null ? toDouble(json['unitCost']) : (json['unit_cost'] != null ? toDouble(json['unit_cost']) : null),
      referenceNumber: (json['referenceNumber'] ?? json['reference_number']) as String?,
      notes: json['notes'] as String?,
      movementDate: json['movementDate'] != null
          ? DateTime.parse(json['movementDate'] as String)
          : (json['movement_date'] != null
              ? DateTime.parse(json['movement_date'] as String)
              : DateTime.now()),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
