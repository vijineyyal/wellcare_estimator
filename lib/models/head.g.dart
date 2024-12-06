// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'head.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HeadAdapter extends TypeAdapter<Head> {
  @override
  final int typeId = 2;

  @override
  Head read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Head(
      id: fields[0] as String,
      name: fields[1] as String,
      enabled: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Head obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
