import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:migoalpilot/core/services/services.dart';

class SecurityService {
  final SecureStorageService _secureStorage;
  static const String _pinHashKey = 'sec_pin_hash';
  static const String _pinSaltKey = 'sec_pin_salt';
  static const String _appLockConfigKey = 'sec_app_lock_enabled';
  static const String _biometricConfigKey = 'sec_biometric_enabled';
  static const String _inactivityConfigKey = 'sec_inactivity_duration';

  SecurityService(this._secureStorage);

  Future<bool> hasPin() async {
    final hash = await _secureStorage.read(_pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _secureStorage.write(_pinHashKey, hash);
    await _secureStorage.write(_pinSaltKey, salt);
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(_pinHashKey);
    final storedSalt = await _secureStorage.read(_pinSaltKey);
    if (storedHash == null || storedSalt == null) return false;

    final inputHash = _hashPin(pin, storedSalt);
    return storedHash == inputHash;
  }

  Future<void> disablePin() async {
    await _secureStorage.delete(_pinHashKey);
    await _secureStorage.delete(_pinSaltKey);
    await setAppLockEnabled(false);
    await setBiometricEnabled(false);
  }

  // App Lock configuration
  Future<bool> isAppLockEnabled() async {
    final val = await _secureStorage.read(_appLockConfigKey);
    return val == 'true';
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    await _secureStorage.write(_appLockConfigKey, enabled ? 'true' : 'false');
  }

  // Biometrics configuration
  Future<bool> isBiometricEnabled() async {
    final val = await _secureStorage.read(_biometricConfigKey);
    return val == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(_biometricConfigKey, enabled ? 'true' : 'false');
  }

  // Inactivity threshold configuration (in seconds, e.g. 0 = immediately, 60 = 1 min, etc.)
  Future<int> getInactivityDuration() async {
    final val = await _secureStorage.read(_inactivityConfigKey);
    if (val == null) return 0; // default is immediately
    return int.tryParse(val) ?? 0;
  }

  Future<void> setInactivityDuration(int seconds) async {
    await _secureStorage.write(_inactivityConfigKey, seconds.toString());
  }

  // Helper hash functions
  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    final rand = Random.secure();
    final values = List<int>.generate(16, (i) => rand.nextInt(256));
    return base64Url.encode(values);
  }
}
