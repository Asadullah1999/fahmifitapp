import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/hive_database.dart';
import '../domain/folder_entity.dart';

class FolderRepository {
  Box<FolderEntity> get _box => HiveDatabase.folders;

  List<FolderEntity> getAll() => _box.values.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  FolderEntity? getById(String id) => _box.get(id);

  Future<FolderEntity> createFolder({
    required String name,
    required String iconEmoji,
    required String colorHex,
  }) async {
    final id = const Uuid().v4();
    final folder = FolderEntity(
      id: id,
      name: name,
      iconEmoji: iconEmoji,
      colorHex: colorHex,
      documentCount: 0,
      createdAt: DateTime.now(),
    );
    await _box.put(id, folder);
    return folder;
  }

  Future<void> updateFolder(FolderEntity folder) async {
    await folder.save();
  }

  Future<void> deleteFolder(String id) async {
    await _box.delete(id);
  }
}
