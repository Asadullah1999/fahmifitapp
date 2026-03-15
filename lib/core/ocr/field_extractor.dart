import '../../features/vault/domain/document_entity.dart';

/// Rule-based document type classifier and field extractor.
class FieldExtractor {
  /// Detects document type using keyword matching.
  DocumentType detectDocumentType(String text) {
    final lower = text.toLowerCase();

    // Passport keywords
    if (_containsAny(lower, ['passport', 'travel document', 'nationality', 'mrz', 'p<'])) {
      return DocumentType.passport;
    }

    // Driver license keywords
    if (_containsAny(lower, ["driver's license", "driver license", "driving licence",
        "dl number", "class d", "motor vehicle"])) {
      return DocumentType.license;
    }

    // Insurance keywords
    if (_containsAny(lower, ['insurance', 'policy number', 'insured', 'coverage',
        'premium', 'deductible'])) {
      return DocumentType.insurance;
    }

    // Medical keywords
    if (_containsAny(lower, ['patient', 'diagnosis', 'prescription', 'medication',
        'dosage', 'physician', 'hospital', 'clinic', 'medical record'])) {
      return DocumentType.medical;
    }

    // Tax keywords
    if (_containsAny(lower, ['tax return', 'form 1040', 'w-2', 'income tax',
        'irs', 'fiscal year', 'taxable income', 'deduction'])) {
      return DocumentType.tax;
    }

    // Contract keywords
    if (_containsAny(lower, ['agreement', 'contract', 'terms and conditions',
        'parties agree', 'whereas', 'hereinafter', 'signed by'])) {
      return DocumentType.contract;
    }

    // Receipt keywords
    if (_containsAny(lower, ['receipt', 'thank you for your purchase', 'total amount',
        'subtotal', 'sales tax', 'order number', 'invoice'])) {
      return DocumentType.receipt;
    }

    // Certificate keywords
    if (_containsAny(lower, ['certificate', 'certify', 'awarded to', 'completion',
        'achievement', 'diploma', 'degree'])) {
      return DocumentType.certificate;
    }

    return DocumentType.other;
  }

  /// Extracts key fields based on document type using regex.
  Map<String, String> extractFields(String text, DocumentType type) {
    switch (type) {
      case DocumentType.passport:
        return _extractPassportFields(text);
      case DocumentType.license:
        return _extractLicenseFields(text);
      case DocumentType.insurance:
        return _extractInsuranceFields(text);
      case DocumentType.medical:
        return _extractMedicalFields(text);
      default:
        return {};
    }
  }

  /// Extracts expiry/validity date from text.
  DateTime? extractExpiryDate(String text, DocumentType type) {
    final patterns = [
      // EXPIRY DATE: DD/MM/YYYY
      RegExp(r'(?:expir(?:y|es?|ation)|valid(?:ity)?\s*(?:until|through|to)?|date\s*of\s*expiry)[:\s]+(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})', caseSensitive: false),
      // Date in various formats
      RegExp(r'(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})'),
      // Month DD, YYYY
      RegExp(r'((?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\.?\s+\d{1,2},?\s+\d{4})', caseSensitive: false),
      // YYYY-MM-DD (ISO)
      RegExp(r'(\d{4}[\/\-\.]\d{2}[\/\-\.]\d{2})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final dateStr = match.group(1) ?? match.group(0) ?? '';
        final parsed = _parseDate(dateStr);
        // Only return if date is in the future (expiry date)
        if (parsed != null && parsed.isAfter(DateTime.now())) {
          return parsed;
        }
      }
    }
    return null;
  }

  Map<String, String> _extractPassportFields(String text) {
    final fields = <String, String>{};

    // Passport number: typically alphanumeric, 6-9 characters
    final passportNo = RegExp(r'passport\s*(?:no|number|#)?[:\s]+([A-Z0-9]{6,9})', caseSensitive: false)
        .firstMatch(text);
    if (passportNo != null) fields['passport_number'] = passportNo.group(1)!;

    // Full name
    final name = RegExp(r'(?:surname|family name|last name)[:\s]+([A-Z\s]+)', caseSensitive: false)
        .firstMatch(text);
    if (name != null) fields['surname'] = name.group(1)!.trim();

    final givenName = RegExp(r'(?:given name|first name)[:\s]+([A-Z\s]+)', caseSensitive: false)
        .firstMatch(text);
    if (givenName != null) fields['given_name'] = givenName.group(1)!.trim();

    // Nationality
    final nationality = RegExp(r'nationality[:\s]+([A-Z\s]+)', caseSensitive: false)
        .firstMatch(text);
    if (nationality != null) fields['nationality'] = nationality.group(1)!.trim();

    // Date of birth
    final dob = RegExp(r'(?:date of birth|dob|birth date)[:\s]+(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})', caseSensitive: false)
        .firstMatch(text);
    if (dob != null) fields['date_of_birth'] = dob.group(1)!;

    return fields;
  }

  Map<String, String> _extractLicenseFields(String text) {
    final fields = <String, String>{};

    final licNo = RegExp(r'(?:license|licence|dl)\s*(?:no|number|#)?[:\s]+([A-Z0-9\-]{4,20})', caseSensitive: false)
        .firstMatch(text);
    if (licNo != null) fields['license_number'] = licNo.group(1)!;

    final address = RegExp(r'(?:address)[:\s]+(.+?)(?:\n|city|state)', caseSensitive: false)
        .firstMatch(text);
    if (address != null) fields['address'] = address.group(1)!.trim();

    return fields;
  }

  Map<String, String> _extractInsuranceFields(String text) {
    final fields = <String, String>{};

    final policyNo = RegExp(r'policy\s*(?:no|number|#)?[:\s]+([A-Z0-9\-]{4,20})', caseSensitive: false)
        .firstMatch(text);
    if (policyNo != null) fields['policy_number'] = policyNo.group(1)!;

    final insured = RegExp(r'(?:insured|policyholder)[:\s]+(.+?)(?:\n|$)', caseSensitive: false)
        .firstMatch(text);
    if (insured != null) fields['insured_name'] = insured.group(1)!.trim();

    return fields;
  }

  Map<String, String> _extractMedicalFields(String text) {
    final fields = <String, String>{};

    final patient = RegExp(r'patient\s*(?:name)?[:\s]+(.+?)(?:\n|$)', caseSensitive: false)
        .firstMatch(text);
    if (patient != null) fields['patient_name'] = patient.group(1)!.trim();

    final doctor = RegExp(r'(?:physician|doctor|dr\.?)[:\s]+(.+?)(?:\n|$)', caseSensitive: false)
        .firstMatch(text);
    if (doctor != null) fields['doctor'] = doctor.group(1)!.trim();

    return fields;
  }

  DateTime? _parseDate(String dateStr) {
    final clean = dateStr.trim();

    // Try ISO format (YYYY-MM-DD)
    try {
      return DateTime.parse(clean);
    } catch (_) {}

    // Try DD/MM/YYYY or MM/DD/YYYY
    final parts = clean.split(RegExp(r'[\/\-\.]'));
    if (parts.length == 3) {
      final nums = parts.map(int.tryParse).toList();
      if (nums.every((n) => n != null)) {
        int day, month, year;

        if (nums[2]! > 31) {
          // YYYY-MM-DD
          year = nums[0]!;
          month = nums[1]!;
          day = nums[2]!;
        } else if (nums[0]! > 12) {
          // DD/MM/YYYY
          day = nums[0]!;
          month = nums[1]!;
          year = nums[2]!;
        } else {
          // Assume DD/MM/YYYY
          day = nums[0]!;
          month = nums[1]!;
          year = nums[2]!;
        }

        if (year < 100) year += 2000;

        try {
          return DateTime(year, month, day);
        } catch (_) {}
      }
    }

    return null;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}
