// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveUserProfileAdapter extends TypeAdapter<HiveUserProfile> {
  @override
  final int typeId = 0;

  @override
  HiveUserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUserProfile()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..email = fields[2] as String
      ..avatarUrl = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, HiveUserProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.avatarUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveUserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
