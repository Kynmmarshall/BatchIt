// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_batch.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveBatchAdapter extends TypeAdapter<HiveBatch> {
  @override
  final int typeId = 1;

  @override
  HiveBatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveBatch()
      ..id = fields[0] as String
      ..productName = fields[1] as String
      ..bulkSizeKg = fields[2] as double
      ..currentQuantityKg = fields[3] as double
      ..locationName = fields[4] as String
      ..hubName = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, HiveBatch obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.bulkSizeKg)
      ..writeByte(3)
      ..write(obj.currentQuantityKg)
      ..writeByte(4)
      ..write(obj.locationName)
      ..writeByte(5)
      ..write(obj.hubName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveBatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
