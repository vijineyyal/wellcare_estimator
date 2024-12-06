// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost_component.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CostComponentAdapter extends TypeAdapter<CostComponent> {
  @override
  final int typeId = 0;

  @override
  CostComponent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CostComponent(
      id: fields[0] as String,
      name: fields[1] as String,
      headId: fields[2] as String,
      unitPrice: fields[3] as double?,
      unit: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CostComponent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.headId)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CostComponentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
