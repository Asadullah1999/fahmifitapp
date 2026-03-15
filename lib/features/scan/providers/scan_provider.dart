import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ocr/ocr_service.dart';
import '../../../core/ocr/field_extractor.dart';
import '../../../core/encryption/encryption_service.dart';
import '../../../core/encryption/key_manager.dart';
import '../../vault/data/document_repository.dart';
import '../../vault/domain/document_entity.dart';

final keyManagerProvider = Provider((ref) => KeyManager());

final encryptionServiceProvider = Provider((ref) {
  return EncryptionService(ref.read(keyManagerProvider));
});

final documentRepositoryProvider = Provider((ref) {
  return DocumentRepository(ref.read(encryptionServiceProvider));
});

final ocrServiceProvider = Provider((ref) => OcrService());

// State for the current scan session
class ScanState {
  final List<String> capturedImagePaths;
  final bool isProcessing;
  final OcrResult? ocrResult;
  final String? error;

  const ScanState({
    this.capturedImagePaths = const [],
    this.isProcessing = false,
    this.ocrResult,
    this.error,
  });

  ScanState copyWith({
    List<String>? capturedImagePaths,
    bool? isProcessing,
    OcrResult? ocrResult,
    String? error,
  }) {
    return ScanState(
      capturedImagePaths: capturedImagePaths ?? this.capturedImagePaths,
      isProcessing: isProcessing ?? this.isProcessing,
      ocrResult: ocrResult ?? this.ocrResult,
      error: error ?? this.error,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final OcrService _ocrService;
  final DocumentRepository _repository;

  ScanNotifier(this._ocrService, this._repository)
      : super(const ScanState());

  void addCapture(String imagePath) {
    state = state.copyWith(
      capturedImagePaths: [...state.capturedImagePaths, imagePath],
    );
  }

  void removeCapture(int index) {
    final paths = List<String>.from(state.capturedImagePaths);
    paths.removeAt(index);
    state = state.copyWith(capturedImagePaths: paths);
  }

  void clearCaptures() {
    state = const ScanState();
  }

  Future<OcrResult?> runOcr() async {
    if (state.capturedImagePaths.isEmpty) return null;

    state = state.copyWith(isProcessing: true);
    try {
      final images = state.capturedImagePaths.map(File.new).toList();
      final result = await _ocrService.processImages(images);
      state = state.copyWith(isProcessing: false, ocrResult: result);
      return result;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return null;
    }
  }

  Future<DocumentEntity?> saveDocument({
    required String title,
    required String folderId,
    required DocumentType type,
    DateTime? expiryDate,
    List<String>? tags,
  }) async {
    if (state.capturedImagePaths.isEmpty) return null;

    // Check free tier limit
    if (_repository.hasReachedFreeLimit) {
      state = state.copyWith(error: 'FREE_LIMIT_REACHED');
      return null;
    }

    state = state.copyWith(isProcessing: true);
    try {
      final doc = await _repository.saveDocument(
        imagePaths: state.capturedImagePaths,
        title: title,
        folderId: folderId,
        type: type,
        ocrText: state.ocrResult?.fullText,
        extractedFields: state.ocrResult?.extractedFields,
        expiryDate: expiryDate ?? state.ocrResult?.extractedExpiryDate,
        tags: tags,
      );
      state = const ScanState();
      return doc;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return null;
    }
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(
    ref.read(ocrServiceProvider),
    ref.read(documentRepositoryProvider),
  );
});
