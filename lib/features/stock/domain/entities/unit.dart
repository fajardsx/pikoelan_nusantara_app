import 'package:restauran_menu/core/common/common_utils.dart';

class Unit {
  final int id;
  final String name;
  final String? symbol;
  final double? conversionFactor;
  final String? baseUnit;
  final String? description;
  final bool? isActive;

  Unit({
    required this.id,
    required this.name,
    this.symbol,
    this.conversionFactor,
    this.baseUnit,
    this.description,
    this.isActive,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      name: json['name'] as String,
      symbol: json['symbol'] as String?,
      conversionFactor: json['conversionFactor'] != null
          ? toDouble(json['conversionFactor'])
          : null,
      baseUnit: json['baseUnit'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] != null ? json['isActive'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isActive': isActive,
    if (symbol != null && symbol!.isNotEmpty) 'symbol': symbol,
    if (conversionFactor != null) 'conversionFactor': conversionFactor,
    if (baseUnit != null && baseUnit!.isNotEmpty) 'baseUnit': baseUnit,
    if (description != null && description!.isNotEmpty)
      'description': description,
  };
}
