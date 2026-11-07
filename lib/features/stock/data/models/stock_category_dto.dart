class StockCategoryDto {
  final String name;
  final String? description;
  final bool? isActive;

  StockCategoryDto({
    required this.name,
    this.description,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'isActive': isActive,
  };
}
