import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }
}

class ConnectivityService {
  Future<bool> get isConnected async {
    return true;
  }
}
