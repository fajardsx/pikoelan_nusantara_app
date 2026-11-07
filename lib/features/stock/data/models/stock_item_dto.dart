import 'package:restauran_menu/core/common/common_utils.dart';

class StockItemDto {
  final int? id;
  final int tenantId;
  final int? categoryId;
  final int unitId;
  final String? sku;
  final String name;
  final String? description;
  final double currentStock;
  final double minimumStock;
  final double? costPrice;
  final String? supplier;
  final String? notes;
  final bool isActive;

  StockItemDto({
    this.id,
    required this.tenantId,
    this.categoryId,
    required this.unitId,
    this.sku,
    required this.name,
    this.description,
    required this.currentStock,
    required this.minimumStock,
    this.costPrice,
    this.supplier,
    this.notes,
    required this.isActive,
  });

  factory StockItemDto.fromJson(Map<String, dynamic> json) => StockItemDto(
    id: json['id'] as int?,
    tenantId: json['tenantId'] as int,
    categoryId: json['categoryId'] as int?,
    unitId: json['unitId'] as int,
    sku: json['sku'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    currentStock: toDouble(json['currentStock']),
    minimumStock: toDouble(json['minimumStock']),
    costPrice: json['costPrice'] != null ? toDouble(json['costPrice']) : null,
    supplier: json['supplier'] as String?,
    notes: json['notes'] as String?,
    isActive: json['isActive'] as bool,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'tenantId': tenantId,
    if (categoryId != null) 'categoryId': categoryId,
    'unitId': unitId,
    if (sku != null) 'sku': sku,
    'name': name,
    if (description != null) 'description': description,
    'currentStock': currentStock,
    'minimumStock': minimumStock,
    if (costPrice != null) 'costPrice': costPrice,
    if (supplier != null) 'supplier': supplier,
    if (notes != null) 'notes': notes,
    'isActive': isActive,
  };
}
