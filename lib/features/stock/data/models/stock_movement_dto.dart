import '../../domain/entities/stock_movement.dart';

class StockMovementDto {
  final int? id;
  final int stockItemId;
  final StockMovementType type;
  final StockMovementReason reason;
  final double quantity;
  final double? unitCost;
  final String? referenceNumber;
  final String? notes;
  final DateTime movementDate;

  StockMovementDto({
    this.id,
    required this.stockItemId,
    required this.type,
    required this.reason,
    required this.quantity,
    this.unitCost,
    this.referenceNumber,
    this.notes,
    required this.movementDate,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'stockItemId': stockItemId,
        'type': type.value,
        'reason': reason.value,
        'quantity': quantity,
        if (unitCost != null) 'unitCost': unitCost,
        if (referenceNumber != null && referenceNumber!.isNotEmpty)
          'referenceNumber': referenceNumber,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        'movementDate': movementDate.toIso8601String(),
      };

  factory StockMovementDto.fromJson(Map<String, dynamic> json) =>
      StockMovementDto(
        id: json['id'] as int?,
        stockItemId: json['stockItemId'] as int,
        type: StockMovementType.fromString(json['type'] as String),
        reason: StockMovementReason.fromString(json['reason'] as String),
        quantity: (json['quantity'] as num).toDouble(),
        unitCost: json['unitCost'] != null
            ? (json['unitCost'] as num).toDouble()
            : null,
        referenceNumber: json['referenceNumber'] as String?,
        notes: json['notes'] as String?,
        movementDate: DateTime.parse(json['movementDate'] as String),
      );
}
