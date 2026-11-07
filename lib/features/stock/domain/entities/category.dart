class Category {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] != null
          ? json['description'] as String
          : "",
      isActive: json['isActive'] != null ? json['isActive'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'isActive': isActive,
  };
}
