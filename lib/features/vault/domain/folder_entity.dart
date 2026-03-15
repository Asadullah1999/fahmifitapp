import 'package:hive_flutter/hive_flutter.dart';

part 'folder_entity.g.dart';

@HiveType(typeId: 2)
class FolderEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String iconEmoji;

  @HiveField(3)
  String colorHex;

  @HiveField(4)
  int documentCount;

  @HiveField(5)
  final DateTime createdAt;

  FolderEntity({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.colorHex,
    required this.documentCount,
    required this.createdAt,
  });
}
