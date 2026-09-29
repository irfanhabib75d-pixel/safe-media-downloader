import 'package:flutter/foundation.dart';
import 'package:permission_media_downloader/models/provider_account.dart';
import 'package:permission_media_downloader/services/security/secure_storage_service.dart';

class AuthNotifier extends ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  final Map<String, ProviderAccount> _accounts = {
    'wikimedia': const ProviderAccount(
      providerId: 'wikimedia',
      providerName: 'Wikimedia Commons',
      isConnected: true,
      accountUsername: 'Open Public API (No key required)',
    ),
    'internet_archive': const ProviderAccount(
      providerId: 'internet_archive',
      providerName: 'Internet Archive',
      isConnected: true,
      accountUsername: 'Open Metadata API',
    ),
    'flickr': const ProviderAccount(
      providerId: 'flickr',
      providerName: 'Flickr',
      isConnected: true,
      accountUsername: 'Default Public Key Active',
      isCustomApiKey: false,
    ),
    'pexels': const ProviderAccount(
      providerId: 'pexels',
      providerName: 'Pexels',
      isConnected: true,
      accountUsername: 'Default Pexels Key Active',
      isCustomApiKey: false,
    ),
    'reddit': const ProviderAccount(
      providerId: 'reddit',
      providerName: 'Reddit',
      isConnected: true,
      accountUsername: 'Public API Client',
    ),
  };

  Map<String, ProviderAccount> get accounts => Map.unmodifiable(_accounts);

  Future<void> loadCustomKeys() async {
    for (final id in _accounts.keys) {
      final customKey = await _secureStorage.readSecureToken(SecureStorageService.providerApiKey(id));
      if (customKey != null && customKey.isNotEmpty) {
        _accounts[id] = _accounts[id]!.copyWith(
          isConnected: true,
          accountUsername: 'Custom API Key Active',
          isCustomApiKey: true,
        );
      }
    }
    notifyListeners();
  }

  Future<void> setCustomApiKey(String providerId, String apiKey) async {
    if (apiKey.trim().isEmpty) {
      await _secureStorage.deleteSecureToken(SecureStorageService.providerApiKey(providerId));
      _accounts[providerId] = _accounts[providerId]!.copyWith(
        accountUsername: 'Default Key',
        isCustomApiKey: false,
      );
    } else {
      await _secureStorage.writeSecureToken(
        SecureStorageService.providerApiKey(providerId),
        apiKey.trim(),
      );
      _accounts[providerId] = _accounts[providerId]!.copyWith(
        isConnected: true,
        accountUsername: 'Custom API Key Saved',
        isCustomApiKey: true,
      );
    }
    notifyListeners();
  }

  Future<String?> getCustomApiKey(String providerId) async {
    return _secureStorage.readSecureToken(SecureStorageService.providerApiKey(providerId));
  }
}
