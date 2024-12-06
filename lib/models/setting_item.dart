import 'package:hive/hive.dart';

part 'setting_item.g.dart';

@HiveType(typeId: 3)
class SettingItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double defaultValue;

  @HiveField(3)
  bool enabled;

  @HiveField(4)
  String type; // 'tax' or 'profit'

  @HiveField(5)
  bool isPercentage; // true for percentage, false for amount

  SettingItem({
    required this.id,
    required this.name,
    required this.defaultValue,
    this.enabled = true,
    required this.type,
    required this.isPercentage,
  });
} 