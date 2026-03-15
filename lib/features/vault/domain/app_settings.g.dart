// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      hasCompletedOnboarding: fields[0] as bool,
      isPremium: fields[1] as bool,
      isBiometricEnabled: fields[2] as bool,
      isCloudBackupEnabled: fields[3] as bool,
      reminderDaysBeforeExpiry: fields[4] as int,
      isDarkMode: fields[5] as bool,
      premiumExpiryDate: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(1)
      ..write(obj.isPremium)
      ..writeByte(2)
      ..write(obj.isBiometricEnabled)
      ..writeByte(3)
      ..write(obj.isCloudBackupEnabled)
      ..writeByte(4)
      ..write(obj.reminderDaysBeforeExpiry)
      ..writeByte(5)
      ..write(obj.isDarkMode)
      ..writeByte(6)
      ..write(obj.premiumExpiryDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
