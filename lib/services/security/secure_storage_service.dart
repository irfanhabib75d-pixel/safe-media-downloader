import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._internal();

  factory SecureStorageService() => instance;

  SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // In-memory fallback if platform secure storage is not available in unit testing
  final Map<String, String> _memoryFallback = {};

  Future<void> writeSecureToken(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (_) {
      _memoryFallback[key] = value;
    }
  }

  Future<String?> readSecureToken(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value ?? _memoryFallback[key];
    } catch (_) {
      return _memoryFallback[key];
    }
  }

  Future<void> deleteSecureToken(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (_) {}
    _memoryFallback.remove(key);
  }

  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    _memoryFallback.clear();
  }

  // Keys
  static String providerApiKey(String providerId) => 'sec_api_key_$providerId';
  static String providerOAuthToken(String providerId) => 'sec_oauth_token_$providerId';
}
