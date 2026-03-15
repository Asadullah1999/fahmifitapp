import 'package:hive_flutter/hive_flutter.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool hasCompletedOnboarding;

  @HiveField(1)
  bool isPremium;

  @HiveField(2)
  bool isBiometricEnabled;

  @HiveField(3)
  bool isCloudBackupEnabled;

  @HiveField(4)
  int reminderDaysBeforeExpiry;

  @HiveField(5)
  bool isDarkMode;

  @HiveField(6)
  String? premiumExpiryDate;

  AppSettings({
    required this.hasCompletedOnboarding,
    required this.isPremium,
    required this.isBiometricEnabled,
    required this.isCloudBackupEnabled,
    required this.reminderDaysBeforeExpiry,
    required this.isDarkMode,
    this.premiumExpiryDate,
  });
}
