import 'package:equatable/equatable.dart';

class MenuCategoryEntity extends Equatable {
  final int id;
  final String name;
  final String? categoriesPicture;
  final int sortOrder;
  final bool isActive;

  const MenuCategoryEntity({
    required this.id,
    required this.name,
    this.categoriesPicture,
    required this.sortOrder,
    required this.isActive,
  });

  factory MenuCategoryEntity.fromJson(Map<String, dynamic> json) {
    return MenuCategoryEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      categoriesPicture: json['categoriesPicture'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, categoriesPicture, sortOrder, isActive];
}
