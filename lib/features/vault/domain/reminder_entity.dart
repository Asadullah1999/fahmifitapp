import 'package:hive_flutter/hive_flutter.dart';

part 'reminder_entity.g.dart';

@HiveType(typeId: 3)
class ReminderEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String documentId;

  @HiveField(2)
  DateTime reminderDate;

  @HiveField(3)
  String message;

  @HiveField(4)
  bool isActive;

  ReminderEntity({
    required this.id,
    required this.documentId,
    required this.reminderDate,
    required this.message,
    this.isActive = true,
  });
}
