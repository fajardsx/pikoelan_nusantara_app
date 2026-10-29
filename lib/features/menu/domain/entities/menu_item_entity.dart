import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final int id;
  final int? categoryId;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final bool isAvailable;
  final bool isFavorite;
  final bool isBanner;
  final int sortOrder;

  const MenuItemEntity({
    required this.id,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    this.isAvailable = true,
    this.isFavorite = false,
    this.isBanner = false,
    this.sortOrder = -1,
  });

  factory MenuItemEntity.fromJson(Map<String, dynamic> json) {
    final numPrice = (json['price'] is num)
        ? (json['price'] as num).toDouble()
        : double.tryParse(json['price'].toString().replaceAll(',', '.')) ?? 0.0;
    final numOriPrice = json['originalPrice'] != null
        ? double.tryParse(json['originalPrice'].toString())
        : null;
    return MenuItemEntity(
      id: json['id'] as int,
      categoryId: int.parse(json['categoryId'].toString()),
      name: json['name'] as String? ?? '',
      price: numPrice,
      originalPrice: numOriPrice,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isBanner: json['isBanner'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      description: json['description'] as String?,
    );
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    price,
    imageUrl,
    isAvailable,
    isFavorite,
    isBanner,
  ];
}
