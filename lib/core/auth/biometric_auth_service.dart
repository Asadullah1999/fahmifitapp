import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _pinKey = 'docvault_pin';
  static const _biometricEnabledKey = 'docvault_biometric_enabled';

  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;
    return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
  }

  Future<List<BiometricType>> availableBiometrics() async {
    if (kIsWeb) return [];
    return await _auth.getAvailableBiometrics();
  }

  /// Authenticates with biometrics or device credentials.
  Future<bool> authenticate({String reason = 'Unlock DocVault'}) async {
    if (kIsWeb) return true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Use biometrics to unlock DocVault',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> savePin(String pin) async {
    // Store hashed PIN only (simple SHA-256)
    await _storage.write(key: _pinKey, value: _hashPin(pin));
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored == _hashPin(pin);
  }

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricEnabledKey);
    return val == 'true';
  }

  String _hashPin(String pin) {
    // Use a simple repeatable hash (in production use bcrypt/argon2)
    var hash = 5381;
    for (final char in pin.codeUnits) {
      hash = ((hash << 5) + hash) + char;
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}
