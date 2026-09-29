import 'dart:io';

class UrlValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Uri? parsedUri;

  const UrlValidationResult({
    required this.isValid,
    this.errorMessage,
    this.parsedUri,
  });

  factory UrlValidationResult.valid(Uri uri) =>
      UrlValidationResult(isValid: true, parsedUri: uri);

  factory UrlValidationResult.invalid(String message) =>
      UrlValidationResult(isValid: false, errorMessage: message);
}

class UrlValidator {
  // Disallowed IP ranges and loopback names for SSRF prevention
  static final RegExp _ipv4Pattern = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');

  static UrlValidationResult validateInputUrl(String rawUrl) {
    if (rawUrl.trim().isEmpty) {
      return UrlValidationResult.invalid('Please enter a URL.');
    }

    final trimmed = rawUrl.trim();

    // Enforce HTTPS
    if (!trimmed.startsWith('https://')) {
      if (trimmed.startsWith('http://')) {
        return UrlValidationResult.invalid(
            'Insecure HTTP connections are not permitted. The URL must use HTTPS (https://).');
      }
      return UrlValidationResult.invalid('Invalid URL format. Must start with https://');
    }

    Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (e) {
      return UrlValidationResult.invalid('Malformed URL syntax.');
    }

    if (!uri.hasScheme || uri.scheme.toLowerCase() != 'https') {
      return UrlValidationResult.invalid('Only HTTPS protocol is supported.');
    }

    if (!uri.hasAuthority || uri.host.trim().isEmpty) {
      return UrlValidationResult.invalid('URL must contain a valid domain host.');
    }

    // SSRF / Local IP check
    final host = uri.host.toLowerCase().trim();
    if (_isPrivateOrLoopbackHost(host)) {
      return UrlValidationResult.invalid(
          'Connections to localhost or internal network IP addresses are forbidden.');
    }

    // Prevent credentials in URL
    if (uri.userInfo.isNotEmpty) {
      return UrlValidationResult.invalid(
          'User credentials embedded in URL authority are not allowed.');
    }

    return UrlValidationResult.valid(uri);
  }

  static bool isHostAllowed(String host, List<String> allowedHosts) {
    final lowerHost = host.toLowerCase();
    for (final pattern in allowedHosts) {
      final lowerPattern = pattern.toLowerCase();
      if (lowerPattern.startsWith('*.')) {
        final root = lowerPattern.substring(2);
        if (lowerHost == root || lowerHost.endsWith('.$root')) {
          return true;
        }
      } else {
        if (lowerHost == lowerPattern) {
          return true;
        }
      }
    }
    return false;
  }

  static bool validateDownloadRedirect(Uri redirectUri, List<String> allowedHosts) {
    if (redirectUri.scheme.toLowerCase() != 'https') {
      return false;
    }
    final host = redirectUri.host.toLowerCase();
    if (_isPrivateOrLoopbackHost(host)) {
      return false;
    }
    return isHostAllowed(host, allowedHosts);
  }

  static bool _isPrivateOrLoopbackHost(String host) {
    if (host == 'localhost' ||
        host.endsWith('.localhost') ||
        host.endsWith('.local') ||
        host.endsWith('.internal')) {
      return true;
    }

    final match = _ipv4Pattern.firstMatch(host);
    if (match != null) {
      final a = int.tryParse(match.group(1)!) ?? 0;
      final b = int.tryParse(match.group(2)!) ?? 0;

      // 127.0.0.0/8 (Loopback)
      if (a == 127) return true;
      // 10.0.0.0/8 (Private)
      if (a == 10) return true;
      // 172.16.0.0/12 (Private)
      if (a == 172 && (b >= 16 && b <= 31)) return true;
      // 192.168.0.0/16 (Private)
      if (a == 192 && b == 168) return true;
      // 169.254.0.0/16 (Link-Local)
      if (a == 169 && b == 254) return true;
      // 0.0.0.0
      if (a == 0) return true;
    }

    // IPv6 checks
    if (host.startsWith('[') && host.endsWith(']')) {
      final cleanIpv6 = host.substring(1, host.length - 1);
      if (cleanIpv6 == '::1' || cleanIpv6.startsWith('fe80:') || cleanIpv6.startsWith('fc00:')) {
        return true;
      }
    }

    return false;
  }
}
