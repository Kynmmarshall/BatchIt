// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveOrderAdapter extends TypeAdapter<HiveOrder> {
  @override
  final int typeId = 3;

  @override
  HiveOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveOrder()
      ..id = fields[0] as String
      ..productName = fields[1] as String
      ..quantityKg = fields[2] as double
      ..status = fields[3] as OrderStatusHive
      ..hubName = fields[4] as String
      ..batchId = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, HiveOrder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantityKg)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.hubName)
      ..writeByte(5)
      ..write(obj.batchId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderStatusHiveAdapter extends TypeAdapter<OrderStatusHive> {
  @override
  final int typeId = 2;

  @override
  OrderStatusHive read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderStatusHive.pending;
      case 1:
        return OrderStatusHive.triggered;
      case 2:
        return OrderStatusHive.delivered;
      case 3:
        return OrderStatusHive.completed;
      default:
        return OrderStatusHive.pending;
    }
  }

  @override
  void write(BinaryWriter writer, OrderStatusHive obj) {
    switch (obj) {
      case OrderStatusHive.pending:
        writer.writeByte(0);
        break;
      case OrderStatusHive.triggered:
        writer.writeByte(1);
        break;
      case OrderStatusHive.delivered:
        writer.writeByte(2);
        break;
      case OrderStatusHive.completed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatusHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
