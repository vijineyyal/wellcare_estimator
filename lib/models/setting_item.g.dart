// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingItemAdapter extends TypeAdapter<SettingItem> {
  @override
  final int typeId = 3;

  @override
  SettingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingItem(
      id: fields[0] as String,
      name: fields[1] as String,
      defaultValue: fields[2] as double,
      enabled: fields[3] as bool,
      type: fields[4] as String,
      isPercentage: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.defaultValue)
      ..writeByte(3)
      ..write(obj.enabled)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isPercentage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
