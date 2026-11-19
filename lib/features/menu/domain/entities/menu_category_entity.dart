import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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
    debugPrint("categories : $json");
    return MenuCategoryEntity(
      id: json['id'] as int,
      name: json['name'] ?? '',
      categoriesPicture: json['categoriesPicture'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, categoriesPicture, sortOrder, isActive];
}
