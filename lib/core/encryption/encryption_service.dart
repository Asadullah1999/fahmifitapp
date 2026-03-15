import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

import 'key_manager.dart';

/// AES-256-GCM encryption service for document files.
/// All documents are encrypted before writing to disk.
class EncryptionService {
  final KeyManager _keyManager;

  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 12;  // 96 bits (GCM standard)
  static const int _tagLength = 16; // 128 bits

  EncryptionService(this._keyManager);

  /// Encrypts [sourceFile] and writes to [destPath].
  /// Returns the encrypted file.
  Future<File> encryptFile(File sourceFile, String destPath) async {
    final key = await _keyManager.getMasterKey();
    final plaintext = await sourceFile.readAsBytes();
    final encrypted = _encryptBytes(plaintext, key);
    final dest = File(destPath);
    await dest.writeAsBytes(encrypted);
    return dest;
  }

  /// Decrypts [encryptedFile] and returns plaintext bytes.
  Future<Uint8List> decryptFile(File encryptedFile) async {
    final key = await _keyManager.getMasterKey();
    final ciphertext = await encryptedFile.readAsBytes();
    return _decryptBytes(ciphertext, key);
  }

  /// Encrypts bytes using AES-256-GCM.
  /// Format: [IV (12 bytes)] + [Tag (16 bytes)] + [Ciphertext]
  Uint8List _encryptBytes(Uint8List plaintext, Uint8List key) {
    final iv = _generateIv();

    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(key),
      _tagLength * 8,
      iv,
      Uint8List(0), // no AAD
    );
    cipher.init(true, params);

    final ciphertext = cipher.process(plaintext);

    // Prepend IV to the output (tag is appended by GCMBlockCipher)
    final result = Uint8List(_ivLength + ciphertext.length);
    result.setRange(0, _ivLength, iv);
    result.setRange(_ivLength, result.length, ciphertext);
    return result;
  }

  /// Decrypts AES-256-GCM encrypted bytes.
  Uint8List _decryptBytes(Uint8List data, Uint8List key) {
    final iv = data.sublist(0, _ivLength);
    final ciphertextWithTag = data.sublist(_ivLength);

    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(key),
      _tagLength * 8,
      iv,
      Uint8List(0),
    );
    cipher.init(false, params);

    return cipher.process(ciphertextWithTag);
  }

  /// Encrypts a string and returns base64-like hex string.
  Future<String> encryptString(String plaintext) async {
    final key = await _keyManager.getMasterKey();
    final bytes = Uint8List.fromList(plaintext.codeUnits);
    final encrypted = _encryptBytes(bytes, key);
    return hex.encode(encrypted);
  }

  /// Decrypts a hex-encoded encrypted string.
  Future<String> decryptString(String encryptedHex) async {
    final key = await _keyManager.getMasterKey();
    final bytes = Uint8List.fromList(hex.decode(encryptedHex));
    final decrypted = _decryptBytes(bytes, key);
    return String.fromCharCodes(decrypted);
  }

  Uint8List _generateIv() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(_ivLength, (_) => random.nextInt(256)),
    );
  }
}
