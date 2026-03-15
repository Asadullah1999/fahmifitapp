import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/database/hive_database.dart';
import '../../../core/encryption/encryption_service.dart';
import '../domain/document_entity.dart';

const _freeDocumentLimit = 20;

class DocumentRepository {
  final EncryptionService _encryption;

  DocumentRepository(this._encryption);

  Box<DocumentEntity> get _box => HiveDatabase.documents;

  List<DocumentEntity> getAll() => _box.values.toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<DocumentEntity> getByFolder(String folderId) =>
      _box.values.where((d) => d.folderId == folderId).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  DocumentEntity? getById(String id) => _box.get(id);

  List<DocumentEntity> getExpiringSoon() => _box.values
      .where((d) => d.isExpiringSoon || d.isExpired)
      .toList()
    ..sort((a, b) => (a.expiryDate ?? DateTime(9999))
        .compareTo(b.expiryDate ?? DateTime(9999)));

  List<DocumentEntity> search(String query) {
    final lower = query.toLowerCase();
    return _box.values.where((d) {
      return d.title.toLowerCase().contains(lower) ||
          (d.ocrText?.toLowerCase().contains(lower) ?? false) ||
          d.type.displayName.toLowerCase().contains(lower) ||
          d.tags.any((t) => t.toLowerCase().contains(lower));
    }).toList();
  }

  int get totalCount => _box.length;

  bool get hasReachedFreeLimit => totalCount >= _freeDocumentLimit;

  /// Creates a PDF from image paths, encrypts it, and saves the document.
  Future<DocumentEntity> saveDocument({
    required List<String> imagePaths,
    required String title,
    required String folderId,
    required DocumentType type,
    String? ocrText,
    Map<String, String>? extractedFields,
    DateTime? expiryDate,
    List<String>? tags,
  }) async {
    final id = const Uuid().v4();
    final docsDir = await _getEncryptedDocsDir();

    // Generate PDF from images
    final pdfBytes = await _generatePdf(imagePaths);
    final tempPdfPath = p.join(docsDir, '$id.tmp.pdf');
    await File(tempPdfPath).writeAsBytes(pdfBytes);

    // Encrypt PDF
    final encryptedPath = p.join(docsDir, '$id.enc');
    await _encryption.encryptFile(File(tempPdfPath), encryptedPath);
    await File(tempPdfPath).delete();

    // Generate thumbnail from first image
    final thumbnailPath = p.join(docsDir, '$id.thumb.enc');
    await _encryption.encryptFile(File(imagePaths.first), thumbnailPath);

    final now = DateTime.now();
    final doc = DocumentEntity(
      id: id,
      folderId: folderId,
      title: title,
      type: type,
      createdAt: now,
      updatedAt: now,
      expiryDate: expiryDate,
      encryptedFilePath: encryptedPath,
      thumbnailPath: thumbnailPath,
      ocrText: ocrText,
      extractedFields: extractedFields ?? {},
      tags: tags ?? [],
      pageCount: imagePaths.length,
      fileSizeBytes: await File(encryptedPath).length(),
    );

    await _box.put(id, doc);
    await _updateFolderCount(folderId, 1);

    return doc;
  }

  Future<void> deleteDocument(String id) async {
    final doc = _box.get(id);
    if (doc == null) return;

    // Delete encrypted files
    final encFile = File(doc.encryptedFilePath);
    if (await encFile.exists()) await encFile.delete();

    if (doc.thumbnailPath != null) {
      final thumbFile = File(doc.thumbnailPath!);
      if (await thumbFile.exists()) await thumbFile.delete();
    }

    await _updateFolderCount(doc.folderId, -1);
    await _box.delete(id);
  }

  Future<void> updateDocument(DocumentEntity doc) async {
    doc.updatedAt = DateTime.now();
    await doc.save();
  }

  /// Decrypts and returns the PDF bytes for viewing.
  Future<List<int>> getDecryptedPdfBytes(String documentId) async {
    final doc = _box.get(documentId);
    if (doc == null) throw Exception('Document not found');
    final bytes = await _encryption.decryptFile(File(doc.encryptedFilePath));
    return bytes;
  }

  Future<void> moveDocument(String documentId, String newFolderId) async {
    final doc = _box.get(documentId);
    if (doc == null) return;

    final oldFolderId = doc.folderId;
    doc.folderId = newFolderId;
    doc.updatedAt = DateTime.now();
    await doc.save();

    await _updateFolderCount(oldFolderId, -1);
    await _updateFolderCount(newFolderId, 1);
  }

  Future<List<int>> _generatePdf(List<String> imagePaths) async {
    final doc = pw.Document();
    for (final path in imagePaths) {
      final imageBytes = await File(path).readAsBytes();
      final image = pw.MemoryImage(imageBytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }
    return await doc.save();
  }

  Future<Directory> _getEncryptedDocsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(appDir.path, 'encrypted_docs'));
    if (!await docsDir.exists()) await docsDir.create(recursive: true);
    return docsDir;
  }

  Future<void> _updateFolderCount(String folderId, int delta) async {
    final folder = HiveDatabase.folders.get(folderId);
    if (folder != null) {
      folder.documentCount = (folder.documentCount + delta).clamp(0, 99999);
      await folder.save();
    }
  }
}
