import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_media_downloader/models/media_option.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/services/providers/base_source_adapter.dart';

class InternetArchiveAdapter extends BaseSourceAdapter {
  @override
  MediaSourceInfo get sourceInfo => const MediaSourceInfo(
        id: 'internet_archive',
        displayName: 'Internet Archive',
        domainPattern: 'archive.org, *.archive.org',
        matchDomains: ['archive.org', 'www.archive.org'],
        allowedDownloadHosts: ['archive.org', '*.archive.org', 'ia800000.us.archive.org', 'ia600000.us.archive.org'],
        supportStatus: SourceSupportStatus.supported,
        officialDocUrl: 'https://archive.org/help/aboutapi.htm',
        policySummary:
            'Internet Archive provides open metadata APIs and direct downloads for public domain and Creative Commons archival media.',
        permittedMethod: 'Official Internet Archive Metadata API (archive.org/metadata/{id})',
        requiredScopes: [],
        reviewDate: '2026-09-29',
        requiresOAuth: false,
      );

  @override
  Future<MediaInspectionResult> inspectMedia(Uri uri, {String? authToken, String? apiKey}) async {
    try {
      // 1. Extract Archive Identifier
      String? identifier;
      if (uri.pathSegments.contains('details')) {
        final idx = uri.pathSegments.indexOf('details');
        if (idx + 1 < uri.pathSegments.length) {
          identifier = uri.pathSegments[idx + 1];
        }
      } else if (uri.pathSegments.contains('download')) {
        final idx = uri.pathSegments.indexOf('download');
        if (idx + 1 < uri.pathSegments.length) {
          identifier = uri.pathSegments[idx + 1];
        }
      } else if (uri.pathSegments.isNotEmpty) {
        identifier = uri.pathSegments.first;
      }

      if (identifier == null || identifier.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Could not find an Archive item identifier in the URL.',
          officialAppUrl: uri.toString(),
        );
      }

      // 2. Query official Metadata API
      final apiUrl = Uri.parse('https://archive.org/metadata/$identifier');
      final response = await http.get(
        apiUrl,
        headers: {
          'User-Agent': 'SafeMediaDownloaderApp/1.0 (Mobile App; contact@example.com)',
        },
      );

      if (response.statusCode != 200) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Internet Archive API returned status ${response.statusCode}',
          officialAppUrl: uri.toString(),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final metadata = (data['metadata'] as Map<String, dynamic>?) ?? {};
      final files = (data['files'] as List<dynamic>?) ?? [];
      final serverHost = data['server'] as String? ?? 'ia800000.us.archive.org';
      final dir = data['dir'] as String? ?? '';

      if (files.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'No downloadable media files associated with this archive item.',
        );
      }

      final title = metadata['title'] as String? ?? identifier;
      final creator = metadata['creator'] as String? ?? 'Internet Archive Contributor';
      final licenseUrl = metadata['licenseurl'] as String?;
      final licenseName = metadata['license'] as String? ?? 'Public Domain / Open Access';

      // Find suitable media files (mp4, webm, mp3, flac, jpg, png)
      final options = <MediaOption>[];

      for (final f in files) {
        final fileObj = f as Map<String, dynamic>;
        final fileName = fileObj['name'] as String? ?? '';
        final format = fileObj['format'] as String? ?? '';
        final size = int.tryParse(fileObj['size']?.toString() ?? '0') ?? 0;
        final ext = fileName.split('.').last.toLowerCase();

        // Check if format is safe media
        if (['mp4', 'webm', 'ogv', 'mp3', 'flac', 'ogg', 'jpg', 'jpeg', 'png', 'pdf'].contains(ext)) {
          final downloadUrl = 'https://$serverHost$dir/$fileName';
          final mimeType = _getMimeTypeForExt(ext);

          options.add(
            MediaOption(
              id: fileName,
              label: '$format ($fileName)',
              downloadUrl: downloadUrl,
              mimeType: mimeType,
              fileExtension: ext,
              estimatedSizeBytes: size > 0 ? size : null,
              qualityLabel: format,
            ),
          );
        }
      }

      if (options.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'No compatible media formats (MP4, MP3, JPEG, PNG) available for this item.',
        );
      }

      return MediaInspectionResult(
        isSupported: true,
        providerName: sourceInfo.displayName,
        title: title,
        author: creator,
        sourceWebUrl: uri.toString(),
        licenseName: licenseName,
        licenseUrl: licenseUrl,
        previewThumbnailUrl: 'https://archive.org/services/img/$identifier',
        options: options,
        docReviewRef: sourceInfo.officialDocUrl,
      );
    } catch (e) {
      return MediaInspectionResult.unsupported(
        providerName: sourceInfo.displayName,
        reason: 'Error connecting to Internet Archive API: $e',
        officialAppUrl: uri.toString(),
      );
    }
  }

  static String _getMimeTypeForExt(String ext) {
    switch (ext) {
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'ogv':
        return 'video/ogg';
      case 'mp3':
        return 'audio/mpeg';
      case 'flac':
        return 'audio/flac';
      case 'ogg':
        return 'audio/ogg';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
