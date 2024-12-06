// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estimation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EstimationAdapter extends TypeAdapter<Estimation> {
  @override
  final int typeId = 1;

  @override
  Estimation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Estimation(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      components: (fields[3] as Map).cast<String, double>(),
      taxRate: fields[4] as double?,
      profitMargin: fields[5] as double?,
      overheads: (fields[6] as Map).cast<String, double>(),
      totalCost: fields[7] as double,
      quantities: (fields[8] as Map?)?.cast<String, double>(),
      productName: fields[9] as String,
      componentDetails: (fields[10] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as Map).cast<String, dynamic>())),
      enabledTaxHeads: (fields[11] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      enabledProfitMargins: (fields[12] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      estimationId: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Estimation obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.components)
      ..writeByte(4)
      ..write(obj.taxRate)
      ..writeByte(5)
      ..write(obj.profitMargin)
      ..writeByte(6)
      ..write(obj.overheads)
      ..writeByte(7)
      ..write(obj.totalCost)
      ..writeByte(8)
      ..write(obj.quantities)
      ..writeByte(9)
      ..write(obj.productName)
      ..writeByte(10)
      ..write(obj.componentDetails)
      ..writeByte(11)
      ..write(obj.enabledTaxHeads)
      ..writeByte(12)
      ..write(obj.enabledProfitMargins)
      ..writeByte(13)
      ..write(obj.estimationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EstimationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
