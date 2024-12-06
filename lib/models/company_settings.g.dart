// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanySettingsAdapter extends TypeAdapter<CompanySettings> {
  @override
  final int typeId = 5;

  @override
  CompanySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanySettings(
      companyName: fields[0] as String,
      shortName: fields[1] as String,
      lastEstimationNumber: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CompanySettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.companyName)
      ..writeByte(1)
      ..write(obj.shortName)
      ..writeByte(2)
      ..write(obj.lastEstimationNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
