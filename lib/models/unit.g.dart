// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitAdapter extends TypeAdapter<Unit> {
  @override
  final int typeId = 4;

  @override
  Unit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Unit(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      enabled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Unit obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
