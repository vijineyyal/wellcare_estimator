import 'package:hive/hive.dart';

part 'head.g.dart';

@HiveType(typeId: 2)
class Head extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool enabled;

  Head({
    required this.id,
    required this.name,
    this.enabled = true,
  });
} 