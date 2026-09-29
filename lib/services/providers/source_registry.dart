import 'package:permission_media_downloader/models/media_option.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/services/providers/base_source_adapter.dart';
import 'package:permission_media_downloader/services/providers/flickr_adapter.dart';
import 'package:permission_media_downloader/services/providers/internet_archive_adapter.dart';
import 'package:permission_media_downloader/services/providers/pexels_pixabay_adapter.dart';
import 'package:permission_media_downloader/services/providers/reddit_adapter.dart';
import 'package:permission_media_downloader/services/providers/unsupported_platforms_adapter.dart';
import 'package:permission_media_downloader/services/providers/wikimedia_commons_adapter.dart';
import 'package:permission_media_downloader/services/security/url_validator.dart';

class SourceRegistry {
  static final SourceRegistry instance = SourceRegistry._internal();

  factory SourceRegistry() => instance;

  final List<BaseSourceAdapter> _supportedAdapters = [];
  final List<BaseSourceAdapter> _unsupportedAdapters = [];

  SourceRegistry._internal() {
    _initAdapters();
  }

  void _initAdapters() {
    // 1. Supported Adapters (Official Permission & Open Media APIs)
    _supportedAdapters.addAll([
      WikimediaCommonsAdapter(),
      InternetArchiveAdapter(),
      FlickrAdapter(),
      PexelsAdapter(),
      RedditAdapter(),
    ]);

    // 2. Unsupported Platforms (Explicit Policy Blocks)
    _unsupportedAdapters.addAll(UnsupportedPlatformAdapter.allKnownUnsupported);
  }

  List<BaseSourceAdapter> get allSupportedAdapters => List.unmodifiable(_supportedAdapters);
  List<BaseSourceAdapter> get allUnsupportedAdapters => List.unmodifiable(_unsupportedAdapters);

  List<MediaSourceInfo> getAllSources() {
    return [
      ..._supportedAdapters.map((a) => a.sourceInfo),
      ..._unsupportedAdapters.map((a) => a.sourceInfo),
    ];
  }

  BaseSourceAdapter? findAdapterForUrl(Uri uri) {
    // Check supported first
    for (final adapter in _supportedAdapters) {
      if (adapter.canHandle(uri)) {
        return adapter;
      }
    }

    // Check known unsupported
    for (final adapter in _unsupportedAdapters) {
      if (adapter.canHandle(uri)) {
        return adapter;
      }
    }

    return null;
  }

  bool isSupported(Uri uri) {
    for (final adapter in _supportedAdapters) {
      if (adapter.canHandle(uri)) {
        return true;
      }
    }
    return false;
  }

  Future<MediaInspectionResult> inspectUrl(
    String rawUrl, {
    String? apiKey,
    String? authToken,
  }) async {
    // 1. Validate URL syntax, HTTPS and SSRF safety
    final valResult = UrlValidator.validateInputUrl(rawUrl);
    if (!valResult.isValid || valResult.parsedUri == null) {
      return MediaInspectionResult.unsupported(
        providerName: 'Unknown',
        reason: valResult.errorMessage ?? 'Invalid URL format.',
      );
    }

    final uri = valResult.parsedUri!;

    // 2. Match against registered adapters
    final adapter = findAdapterForUrl(uri);
    if (adapter == null) {
      return MediaInspectionResult.unsupported(
        providerName: uri.host,
        reason:
            'The domain "${uri.host}" is not on the explicit list of officially supported media providers. We only support platforms with documented, authorized download APIs.',
        officialAppUrl: 'https://${uri.host}',
      );
    }

    // 3. Inspect using the adapter
    return adapter.inspectMedia(uri, apiKey: apiKey, authToken: authToken);
  }
}
