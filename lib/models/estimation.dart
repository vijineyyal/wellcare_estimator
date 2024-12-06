import 'package:hive/hive.dart';

part 'estimation.g.dart';

@HiveType(typeId: 1)
class Estimation extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  Map<String, double> components;

  @HiveField(4)
  double? taxRate;

  @HiveField(5)
  double? profitMargin;

  @HiveField(6)
  Map<String, double> overheads;

  @HiveField(7)
  double totalCost;

  @HiveField(8)
  Map<String, double> quantities;

  @HiveField(9)
  String productName;

  @HiveField(10)
  Map<String, Map<String, dynamic>> componentDetails;

  @HiveField(11)
  List<Map<String, dynamic>> enabledTaxHeads;

  @HiveField(12)
  List<Map<String, dynamic>> enabledProfitMargins;

  @HiveField(13)
  String estimationId;

  @HiveField(14)
  int revisionNumber;

  Estimation({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.components,
    this.taxRate,
    this.profitMargin,
    required this.overheads,
    required this.totalCost,
    required this.estimationId,
    this.revisionNumber = 0,
    Map<String, double>? quantities,
    String? productName,
    Map<String, Map<String, dynamic>>? componentDetails,
    List<Map<String, dynamic>>? enabledTaxHeads,
    List<Map<String, dynamic>>? enabledProfitMargins,
  }) : 
    this.quantities = quantities ?? {},
    this.productName = productName ?? '',
    this.componentDetails = componentDetails ?? {},
    this.enabledTaxHeads = enabledTaxHeads ?? [],
    this.enabledProfitMargins = enabledProfitMargins ?? [];

  String getDisplayId() {
    return revisionNumber > 0 
        ? '$estimationId-REV-${revisionNumber.toString().padLeft(3, '0')}'
        : estimationId;
  }
}
