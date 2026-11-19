import 'package:equatable/equatable.dart';
import 'package:restauran_menu/core/common/common_utils.dart';

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
    //debugPrint("menu : $json");
    final numPrice = toDouble(json['price']);
    final numOriPrice = json['originalPrice'] != null
        ? toDouble(json['originalPrice'])
        : null;
    return MenuItemEntity(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int?,
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
