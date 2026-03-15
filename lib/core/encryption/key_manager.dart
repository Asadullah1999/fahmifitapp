import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';

/// Manages AES-256 master key, stored securely in Keychain (iOS) / Keystore (Android).
class KeyManager {
  static const String _masterKeyKey = 'docvault_master_key';
  static const int _keyLength = 32; // 256 bits

  final FlutterSecureStorage _storage;

  KeyManager() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Returns the master encryption key, generating one if not yet created.
  Future<Uint8List> getMasterKey() async {
    final stored = await _storage.read(key: _masterKeyKey);
    if (stored != null) {
      return Uint8List.fromList(hex.decode(stored));
    }
    return await _generateAndStoreMasterKey();
  }

  Future<Uint8List> _generateAndStoreMasterKey() async {
    final random = Random.secure();
    final key = Uint8List.fromList(
      List.generate(_keyLength, (_) => random.nextInt(256)),
    );
    await _storage.write(key: _masterKeyKey, value: hex.encode(key));
    return key;
  }

  /// Derives a key from a PIN using PBKDF2 (for PIN-locked backup export).
  Uint8List deriveKeyFromPin(String pin, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, 100000, _keyLength));
    return pbkdf2.process(Uint8List.fromList(pin.codeUnits));
  }

  /// Generates a random 16-byte salt.
  Uint8List generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(16, (_) => random.nextInt(256)),
    );
  }

  /// Deletes the master key (used on account reset / wipe).
  Future<void> deleteMasterKey() async {
    await _storage.delete(key: _masterKeyKey);
  }
}
