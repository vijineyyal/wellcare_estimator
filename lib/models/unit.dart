import 'package:hive/hive.dart';

part 'unit.g.dart';

@HiveType(typeId: 4)
class Unit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category; // weight, length, volume, etc.

  @HiveField(3)
  bool enabled;

  Unit({
    required this.id,
    required this.name,
    required this.category,
    this.enabled = true,
  });
} 