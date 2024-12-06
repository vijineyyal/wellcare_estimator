import 'package:hive/hive.dart';

part 'company_settings.g.dart';

@HiveType(typeId: 5)
class CompanySettings extends HiveObject {
  @HiveField(0)
  String companyName;

  @HiveField(1)
  String shortName;

  @HiveField(2)
  int lastEstimationNumber;

  CompanySettings({
    required this.companyName,
    required this.shortName,
    this.lastEstimationNumber = 0,
  });

  String getEstimationId() {
    return '$shortName-EST-${(lastEstimationNumber + 1).toString().padLeft(4, '0')}';
  }

  void incrementEstimationNumber() {
    lastEstimationNumber++;
    save();
  }

  void setNextEstimationNumber(int number) {
    lastEstimationNumber = number - 1;  // Subtract 1 since we increment when using
    save();
  }
} 