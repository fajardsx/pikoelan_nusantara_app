import 'package:restauran_menu/core/common/common_utils.dart';

class StockItem {
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

  StockItem({
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

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
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
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'tenantId': tenantId,
    if (categoryId != null) 'categoryId': categoryId,
    'unitId': unitId,
    if (sku != null && sku!.isNotEmpty) 'sku': sku,
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'currentStock': currentStock,
    'minimumStock': minimumStock,
    if (costPrice != null) 'costPrice': costPrice,
    if (supplier != null && supplier!.isNotEmpty) 'supplier': supplier,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'isActive': isActive,
  };
}
