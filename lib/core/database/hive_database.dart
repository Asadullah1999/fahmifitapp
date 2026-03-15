import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/vault/domain/document_entity.dart';
import '../../features/vault/domain/folder_entity.dart';
import '../../features/vault/domain/reminder_entity.dart';
import '../../features/vault/domain/app_settings.dart';

class HiveDatabase {
  static const String documentsBox = 'documents';
  static const String foldersBox = 'folders';
  static const String remindersBox = 'reminders';
  static const String settingsBox = 'settings';

  static Future<void> initialize() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDir.path);
    }

    // Register type adapters
    Hive.registerAdapter(DocumentEntityAdapter());
    Hive.registerAdapter(FolderEntityAdapter());
    Hive.registerAdapter(ReminderEntityAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(DocumentTypeAdapter());

    // Open boxes
    await Hive.openBox<DocumentEntity>(documentsBox);
    await Hive.openBox<FolderEntity>(foldersBox);
    await Hive.openBox<ReminderEntity>(remindersBox);
    await Hive.openBox<AppSettings>(settingsBox);

    // Seed default folders if first launch
    await _seedDefaultFolders();
    await _seedDefaultSettings();
  }

  static Future<void> _seedDefaultFolders() async {
    final box = Hive.box<FolderEntity>(foldersBox);
    if (box.isNotEmpty) return;

    final defaults = [
      FolderEntity(
        id: 'identity',
        name: 'Identity',
        iconEmoji: '🪪',
        colorHex: '#2563EB',
        documentCount: 0,
        createdAt: DateTime.now(),
      ),
      FolderEntity(
        id: 'finance',
        name: 'Finance',
        iconEmoji: '💰',
        colorHex: '#D97706',
        documentCount: 0,
        createdAt: DateTime.now(),
      ),
      FolderEntity(
        id: 'medical',
        name: 'Medical',
        iconEmoji: '🏥',
        colorHex: '#DC2626',
        documentCount: 0,
        createdAt: DateTime.now(),
      ),
      FolderEntity(
        id: 'contracts',
        name: 'Contracts',
        iconEmoji: '📝',
        colorHex: '#0891B2',
        documentCount: 0,
        createdAt: DateTime.now(),
      ),
      FolderEntity(
        id: 'receipts',
        name: 'Receipts',
        iconEmoji: '🧾',
        colorHex: '#65A30D',
        documentCount: 0,
        createdAt: DateTime.now(),
      ),
      FolderEntity(
        id: 'certificates',
        name: 'Certificates',
        iconEmoji: '🎓',
        colorHex: '#DB2777',
        documentCount: 0,
        createdAt: DateTime.now(),
      ),
      FolderEntity(
        id: 'other',
        name: 'Other',
        iconEmoji: '📁',
        colorHex: '#64748B',
        documentCount: 0,
        createdAt: DateTime.now(),
      ),
    ];

    for (final folder in defaults) {
      await box.put(folder.id, folder);
    }
  }

  static Future<void> _seedDefaultSettings() async {
    final box = Hive.box<AppSettings>(settingsBox);
    if (box.get('settings') != null) return;

    await box.put('settings', AppSettings(
      hasCompletedOnboarding: false,
      isPremium: false,
      isBiometricEnabled: false,
      isCloudBackupEnabled: false,
      reminderDaysBeforeExpiry: 180, // 6 months
      isDarkMode: false,
    ));
  }

  static Box<DocumentEntity> get documents =>
      Hive.box<DocumentEntity>(documentsBox);
  static Box<FolderEntity> get folders =>
      Hive.box<FolderEntity>(foldersBox);
  static Box<ReminderEntity> get reminders =>
      Hive.box<ReminderEntity>(remindersBox);
  static Box<AppSettings> get settings =>
      Hive.box<AppSettings>(settingsBox);
}
