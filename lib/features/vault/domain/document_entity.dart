import 'package:hive_flutter/hive_flutter.dart';

part 'document_entity.g.dart';

@HiveType(typeId: 0)
enum DocumentType {
  @HiveField(0)
  passport,
  @HiveField(1)
  license,
  @HiveField(2)
  insurance,
  @HiveField(3)
  tax,
  @HiveField(4)
  contract,
  @HiveField(5)
  receipt,
  @HiveField(6)
  medical,
  @HiveField(7)
  certificate,
  @HiveField(8)
  other,
}

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.license:
        return 'Driver License';
      case DocumentType.insurance:
        return 'Insurance';
      case DocumentType.tax:
        return 'Tax Document';
      case DocumentType.contract:
        return 'Contract';
      case DocumentType.receipt:
        return 'Receipt';
      case DocumentType.medical:
        return 'Medical Report';
      case DocumentType.certificate:
        return 'Certificate';
      case DocumentType.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case DocumentType.passport:
        return '🛂';
      case DocumentType.license:
        return '🪪';
      case DocumentType.insurance:
        return '🛡️';
      case DocumentType.tax:
        return '📊';
      case DocumentType.contract:
        return '📝';
      case DocumentType.receipt:
        return '🧾';
      case DocumentType.medical:
        return '🏥';
      case DocumentType.certificate:
        return '🎓';
      case DocumentType.other:
        return '📄';
    }
  }

  String get suggestedFolderId {
    switch (this) {
      case DocumentType.passport:
      case DocumentType.license:
        return 'identity';
      case DocumentType.insurance:
      case DocumentType.tax:
        return 'finance';
      case DocumentType.medical:
        return 'medical';
      case DocumentType.contract:
        return 'contracts';
      case DocumentType.receipt:
        return 'receipts';
      case DocumentType.certificate:
        return 'certificates';
      case DocumentType.other:
        return 'other';
    }
  }
}

@HiveType(typeId: 1)
class DocumentEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String folderId;

  @HiveField(2)
  String title;

  @HiveField(3)
  DocumentType type;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  DateTime? expiryDate;

  /// Path to AES-256-GCM encrypted PDF file
  @HiveField(7)
  final String encryptedFilePath;

  /// Path to encrypted thumbnail image
  @HiveField(8)
  String? thumbnailPath;

  @HiveField(9)
  List<String> tags;

  /// Full OCR text (encrypted in memory, stored plaintext in Hive for search)
  @HiveField(10)
  String? ocrText;

  /// Key-value pairs extracted by AI classifier
  @HiveField(11)
  Map<String, String> extractedFields;

  @HiveField(12)
  bool hasReminder;

  @HiveField(13)
  int pageCount;

  @HiveField(14)
  int fileSizeBytes;

  DocumentEntity({
    required this.id,
    required this.folderId,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.expiryDate,
    required this.encryptedFilePath,
    this.thumbnailPath,
    List<String>? tags,
    this.ocrText,
    Map<String, String>? extractedFields,
    this.hasReminder = false,
    this.pageCount = 1,
    this.fileSizeBytes = 0,
  })  : tags = tags ?? [],
        extractedFields = extractedFields ?? {};

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    return daysLeft <= 180 && daysLeft >= 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }
}
