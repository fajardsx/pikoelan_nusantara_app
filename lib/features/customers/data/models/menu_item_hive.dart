import 'package:hive_ce/hive_ce.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';

/// Hive-persisted menu item. [id] mirrors the Hive box key so the domain
/// `MenuItem.id` (a String) can round-trip back to `box.put(id, ...)`.
class MenuItemHive {
  MenuItemHive({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.categoryId,
    this.imageUrl,
    this.isFavorite = false,
    this.isAvailable = true,
    this.isBanner = false,
    this.description,
    this.sortOrder = 0,
  });

  int id;
  String name;
  int? price;
  int sortOrder;
  int? originalPrice;
  int? categoryId;
  String? imageUrl;
  bool isFavorite;
  bool isAvailable;
  bool isBanner;
  String? description;

  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      name: name,
      price: double.tryParse(price.toString()) ?? 0.0,
      originalPrice: double.tryParse(originalPrice.toString()) ?? 0.0,
      categoryId: categoryId ?? 0,
      imageUrl: imageUrl,
      isFavorite: isFavorite,
      isAvailable: isAvailable,
      isBanner: isBanner,
      description: description,
      sortOrder: sortOrder,
    );
  }

  static MenuItemHive fromEntity(MenuItemEntity entity, {required int id}) {
    return MenuItemHive(
      id: id,
      name: entity.name,
      price: (entity.price is int
          ? entity.price as int
          : (entity.price).toInt()),
      originalPrice: (entity.originalPrice != null)
          ? (entity.originalPrice is int
                ? entity.originalPrice as int
                : (entity.originalPrice as double).toInt())
          : 0,
      categoryId: entity.categoryId ?? -1,
      imageUrl: entity.imageUrl,
      isFavorite: entity.isFavorite,
      isAvailable: entity.isAvailable,
      isBanner: entity.isBanner,
      description: entity.description,
      sortOrder: entity.sortOrder,
    );
  }
}

/// Hand-written adapter (equivalent to what `hive_ce_generator` would
/// produce) so the project compiles without running `build_runner`.
class MenuItemHiveAdapter extends TypeAdapter<MenuItemHive> {
  @override
  final int typeId = 0;

  @override
  MenuItemHive read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return MenuItemHive(
      id: fields[0] as int,
      name: fields[1] as String,
      price: fields[2] as int?,
      originalPrice: fields[3] as int?,
      categoryId: fields[4] as int?,
      imageUrl: fields[5] as String?,
      isFavorite: fields[6] as bool,
      isAvailable: fields[7] as bool,
      isBanner: fields[8] as bool,
      description: fields[9] as String?,
      sortOrder: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MenuItemHive obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.originalPrice)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.isAvailable)
      ..writeByte(8)
      ..write(obj.isBanner)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.sortOrder);
  }
}
