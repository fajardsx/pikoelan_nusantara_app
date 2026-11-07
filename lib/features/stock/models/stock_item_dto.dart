class StockItemDto {
  final String? id;
  final String? tenantId;
  final String? categoryId;
  final String? unitId;
  final String? sku;
  final String? name;
  final String? description;
  final double? currentStock;
  final double? minimumStock;
  final double? costPrice;
  final String? supplier;
  final String? notes;
  final bool? isActive;

  StockItemDto({
    this.id,
    this.tenantId,
    this.categoryId,
    this.unitId,
    this.sku,
    this.name,
    this.description,
    this.currentStock,
    this.minimumStock,
    this.costPrice,
    this.supplier,
    this.notes,
    this.isActive,
  });

  factory StockItemDto.fromJson(Map<String, dynamic> json) {
    return StockItemDto(
      id: json['id'] as String?,
      tenantId: json['tenantId'] as String?,
      categoryId: json['categoryId'] as String?,
      unitId: json['unitId'] as String?,
      sku: json['sku'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      currentStock: (json['currentStock'] as num?)?.toDouble(),
      minimumStock: (json['minimumStock'] as num?)?.toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      supplier: json['supplier'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'categoryId': categoryId,
      'unitId': unitId,
      'sku': sku,
      'name': name,
      'description': description,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'costPrice': costPrice,
      'supplier': supplier,
      'notes': notes,
      'isActive': isActive,
    };
  }
}
