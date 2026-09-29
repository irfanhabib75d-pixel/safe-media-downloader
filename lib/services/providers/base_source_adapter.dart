import 'package:permission_media_downloader/models/media_option.dart';
import 'package:permission_media_downloader/models/media_source.dart';

abstract class BaseSourceAdapter {
  MediaSourceInfo get sourceInfo;

  bool canHandle(Uri uri) {
    final host = uri.host.toLowerCase();
    for (final domain in sourceInfo.matchDomains) {
      if (domain.startsWith('*.')) {
        final root = domain.substring(2).toLowerCase();
        if (host == root || host.endsWith('.$root')) {
          return true;
        }
      } else {
        if (host == domain.toLowerCase()) {
          return true;
        }
      }
    }
    return false;
  }

  /// Inspect the URL using the platform's official API
  Future<MediaInspectionResult> inspectMedia(Uri uri, {String? authToken, String? apiKey});

  /// Allowed download hosts for media files
  List<String> get allowedDownloadHosts => sourceInfo.allowedDownloadHosts;
}
