enum SourceSupportStatus {
  supported,
  unsupported,
  requiresAuth,
}

class MediaSourceInfo {
  final String id;
  final String displayName;
  final String domainPattern;
  final List<String> matchDomains;
  final List<String> allowedDownloadHosts;
  final SourceSupportStatus supportStatus;
  final String officialDocUrl;
  final String policySummary;
  final String permittedMethod;
  final List<String> requiredScopes;
  final String reviewDate;
  final String? iconName;
  final bool requiresOAuth;

  const MediaSourceInfo({
    required this.id,
    required this.displayName,
    required this.domainPattern,
    required this.matchDomains,
    required this.allowedDownloadHosts,
    required this.supportStatus,
    required this.officialDocUrl,
    required this.policySummary,
    required this.permittedMethod,
    this.requiredScopes = const [],
    required this.reviewDate,
    this.iconName,
    this.requiresOAuth = false,
  });
}
