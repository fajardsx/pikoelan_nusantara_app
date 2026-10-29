import 'package:hive_ce/hive_ce.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_category_entity.dart';

class CategoryHive {
  CategoryHive({this.id, this.name, this.icon, this.sortOrder, this.isActive});
  int? id;
  String? name;
  String? icon;
  bool? isActive;
  int? sortOrder;

  MenuCategoryEntity toEntity() => MenuCategoryEntity(
    id: id ?? 0,
    name: name ?? '',
    categoriesPicture: icon,
    sortOrder: sortOrder ?? 0,
    isActive: isActive ?? true,
  );

  static CategoryHive fromEntity(MenuCategoryEntity e, {int? id}) =>
      CategoryHive(
        id: id ?? e.id,
        name: e.name,
        icon: e.categoriesPicture,
        sortOrder: e.sortOrder,
        isActive: e.isActive,
      );
}

class CategoryHiveAdapter extends TypeAdapter<CategoryHive> {
  @override
  final int typeId = 4;

  @override
  CategoryHive read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryHive(
      id: (fields[0] as int?) ?? 0,
      name: (fields[1] as String?) ?? "",
      icon: (fields[2] as String?) ?? "",
      sortOrder: (fields[3] as int?) ?? 0,
      isActive: (fields[4] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.sortOrder)
      ..writeByte(4)
      ..write(obj.isActive);
  }
}
