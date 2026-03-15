import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'field_extractor.dart';
import '../../features/vault/domain/document_entity.dart';

class OcrResult {
  final String fullText;
  final DocumentType detectedType;
  final Map<String, String> extractedFields;
  final DateTime? extractedExpiryDate;

  const OcrResult({
    required this.fullText,
    required this.detectedType,
    required this.extractedFields,
    this.extractedExpiryDate,
  });
}

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _extractor = FieldExtractor();

  /// Runs OCR on [imageFile] and returns structured result.
  Future<OcrResult> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognized = await _textRecognizer.processImage(inputImage);
    final fullText = recognized.text;

    final type = _extractor.detectDocumentType(fullText);
    final fields = _extractor.extractFields(fullText, type);
    final expiryDate = _extractor.extractExpiryDate(fullText, type);

    return OcrResult(
      fullText: fullText,
      detectedType: type,
      extractedFields: fields,
      extractedExpiryDate: expiryDate,
    );
  }

  /// Processes multiple pages and merges OCR results.
  Future<OcrResult> processImages(List<File> imageFiles) async {
    final results = await Future.wait(imageFiles.map(processImage));

    final mergedText = results.map((r) => r.fullText).join('\n\n--- Page Break ---\n\n');
    final primaryType = results.first.detectedType;
    final mergedFields = <String, String>{};
    for (final r in results) {
      mergedFields.addAll(r.extractedFields);
    }
    final firstExpiry = results
        .map((r) => r.extractedExpiryDate)
        .where((d) => d != null)
        .firstOrNull;

    return OcrResult(
      fullText: mergedText,
      detectedType: primaryType,
      extractedFields: mergedFields,
      extractedExpiryDate: firstExpiry,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
