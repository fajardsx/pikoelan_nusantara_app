class StockUnitDto {
  final String name;
  final String? symbol;
  final double? conversionFactor;
  final String? baseUnit;
  final String? description;

  StockUnitDto({
    required this.name,
    this.symbol,
    this.conversionFactor,
    this.baseUnit,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (symbol != null && symbol!.isNotEmpty) 'symbol': symbol,
        if (conversionFactor != null) 'conversionFactor': conversionFactor,
        if (baseUnit != null && baseUnit!.isNotEmpty) 'baseUnit': baseUnit,
        if (description != null && description!.isNotEmpty)
          'description': description,
      };
}

