import 'package:hive_ce/hive_ce.dart';
import '../../domain/entities/table.dart';

class TableHive {
  TableHive({
    required this.id,
    required this.number,
    required this.statusIndex,
    this.orderNumber,
    this.guestCount,
  });

  int id;
  int number;
  int statusIndex;
  String? orderNumber;
  int? guestCount;

  RestaurantTable toEntity() {
    return RestaurantTable(
      number: number,
      status: TableStatus.values[statusIndex],
      orderNumber: orderNumber,
      guestCount: guestCount,
    );
  }
}

class TableHiveAdapter extends TypeAdapter<TableHive> {
  @override
  final int typeId = 3;

  @override
  TableHive read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return TableHive(
      id: fields[0] as int,
      number: fields[1] as int,
      statusIndex: fields[2] as int,
      orderNumber: fields[3] as String?,
      guestCount: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TableHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.statusIndex)
      ..writeByte(3)
      ..write(obj.orderNumber)
      ..writeByte(4)
      ..write(obj.guestCount);
  }
}
