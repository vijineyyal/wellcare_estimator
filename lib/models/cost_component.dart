import 'package:hive/hive.dart';

part 'cost_component.g.dart';

@HiveType(typeId: 0)
class CostComponent extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String headId;

  @HiveField(3)
  double? unitPrice;

  @HiveField(4)
  String unit;

  CostComponent({
    required this.id,
    required this.name,
    required this.headId,
    this.unitPrice,
    required this.unit,
  });
} 