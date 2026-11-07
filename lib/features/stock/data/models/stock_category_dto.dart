class StockCategoryDto {
  final String name;
  final String? description;

  StockCategoryDto({required this.name, this.description});

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
  };
}
