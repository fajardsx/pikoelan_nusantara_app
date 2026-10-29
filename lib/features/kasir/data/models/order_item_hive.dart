import 'package:hive_ce/hive_ce.dart';

/// Snapshot of a single ordered line item at the time the order was placed
/// (name/price are copied, not live-referenced, so later menu edits never
/// alter historical orders).
class OrderItemHive {
  OrderItemHive({
    required this.menuItemId,
    required this.menuItemName,
    required this.price,
    required this.quantity,
    this.note,
  });

  String menuItemId;
  String menuItemName;
  int price;
  int quantity;
  String? note;
}

class OrderItemHiveAdapter extends TypeAdapter<OrderItemHive> {
  @override
  final int typeId = 1;

  @override
  OrderItemHive read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItemHive(
      menuItemId: fields[0] as String,
      menuItemName: fields[1] as String,
      price: fields[2] as int,
      quantity: fields[3] as int,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItemHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.menuItemId)
      ..writeByte(1)
      ..write(obj.menuItemName)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.note);
  }
}
