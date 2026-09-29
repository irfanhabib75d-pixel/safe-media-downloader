class ProviderAccount {
  final String providerId;
  final String providerName;
  final bool isConnected;
  final String? accountUsername;
  final DateTime? connectedAt;
  final DateTime? tokenExpiresAt;
  final bool isCustomApiKey;

  const ProviderAccount({
    required this.providerId,
    required this.providerName,
    this.isConnected = false,
    this.accountUsername,
    this.connectedAt,
    this.tokenExpiresAt,
    this.isCustomApiKey = false,
  });

  ProviderAccount copyWith({
    String? providerId,
    String? providerName,
    bool? isConnected,
    String? accountUsername,
    DateTime? connectedAt,
    DateTime? tokenExpiresAt,
    bool? isCustomApiKey,
  }) {
    return ProviderAccount(
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      isConnected: isConnected ?? this.isConnected,
      accountUsername: accountUsername ?? this.accountUsername,
      connectedAt: connectedAt ?? this.connectedAt,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      isCustomApiKey: isCustomApiKey ?? this.isCustomApiKey,
    );
  }
}
