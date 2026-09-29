import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_media_downloader/models/media_option.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/services/providers/base_source_adapter.dart';

class WikimediaCommonsAdapter extends BaseSourceAdapter {
  @override
  MediaSourceInfo get sourceInfo => const MediaSourceInfo(
        id: 'wikimedia',
        displayName: 'Wikimedia Commons',
        domainPattern: 'commons.wikimedia.org, *.wikimedia.org',
        matchDomains: ['commons.wikimedia.org', 'en.wikipedia.org', 'wikipedia.org', 'upload.wikimedia.org'],
        allowedDownloadHosts: ['upload.wikimedia.org', 'commons.wikimedia.org'],
        supportStatus: SourceSupportStatus.supported,
        officialDocUrl: 'https://commons.wikimedia.org/wiki/Commons:API',
        policySummary:
            'Wikimedia Commons provides public APIs for CC/Public Domain media with full metadata and download authorization.',
        permittedMethod: 'Official MediaWiki Action API & REST API (imageinfo query)',
        requiredScopes: [],
        reviewDate: '2026-09-29',
        requiresOAuth: false,
      );

  @override
  Future<MediaInspectionResult> inspectMedia(Uri uri, {String? authToken, String? apiKey}) async {
    try {
      // 1. Extract file title from URL
      String? fileName;
      if (uri.path.contains('/wiki/File:')) {
        fileName = uri.path.split('/wiki/File:').last;
      } else if (uri.path.contains('/wiki/')) {
        fileName = uri.path.split('/wiki/').last;
      } else if (uri.pathSegments.isNotEmpty) {
        fileName = uri.pathSegments.last;
      }

      if (fileName == null || fileName.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Could not find a valid Wikimedia File title in the URL.',
          officialAppUrl: 'https://commons.wikimedia.org',
        );
      }

      // Clean up decoded title
      fileName = Uri.decodeComponent(fileName).replaceAll('_', ' ');
      if (!fileName.startsWith('File:')) {
        fileName = 'File:$fileName';
      }

      // 2. Query official MediaWiki Action API
      final apiUrl = Uri.parse('https://commons.wikimedia.org/w/api.php').replace(
        queryParameters: {
          'action': 'query',
          'titles': fileName,
          'prop': 'imageinfo',
          'iiprop': 'url|size|mime|extmetadata|thumburl',
          'iiurlwidth': '1920',
          'format': 'json',
        },
      );

      final response = await http.get(
        apiUrl,
        headers: {
          'User-Agent': 'SafeMediaDownloaderApp/1.0 (Mobile App; contact@example.com) Flutter/3.x',
        },
      );

      if (response.statusCode != 200) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Wikimedia API returned HTTP status ${response.statusCode}',
          officialAppUrl: uri.toString(),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final pages = (data['query']?['pages'] as Map<String, dynamic>?) ?? {};
      if (pages.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'No media page found on Wikimedia Commons for the specified title.',
        );
      }

      final page = pages.values.first as Map<String, dynamic>;
      if (page.containsKey('missing')) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'The specified media file does not exist on Wikimedia Commons.',
        );
      }

      final imageInfoList = (page['imageinfo'] as List<dynamic>?) ?? [];
      if (imageInfoList.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'No image/media metadata found in official Wikimedia API response.',
        );
      }

      final imageInfo = imageInfoList.first as Map<String, dynamic>;
      final originalDownloadUrl = imageInfo['url'] as String? ?? '';
      final thumbUrl = imageInfo['thumburl'] as String? ?? originalDownloadUrl;
      final mimeType = imageInfo['mime'] as String? ?? 'image/jpeg';
      final totalBytes = (imageInfo['size'] as num?)?.toInt() ?? 0;
      final width = (imageInfo['width'] as num?)?.toInt();
      final height = (imageInfo['height'] as num?)?.toInt();

      final extMetadata = (imageInfo['extmetadata'] as Map<String, dynamic>?) ?? {};
      final licenseShort = (extMetadata['LicenseShortName']?['value'] as String?) ?? 'Public Domain / CC';
      final licenseUrl = extMetadata['LicenseUrl']?['value'] as String?;
      final artistHtml = extMetadata['Artist']?['value'] as String?;
      final author = _stripHtml(artistHtml ?? 'Wikimedia Contributor');
      final cleanTitle = (page['title'] as String? ?? fileName).replaceAll('File:', '');

      // Generate download options (Original + Scaled)
      final options = <MediaOption>[];

      // 1. Original Resolution Option
      options.add(
        MediaOption(
          id: 'original',
          label: 'Original Quality (${width != null && height != null ? "${width}x$height" : "Full Resolution"})',
          downloadUrl: originalDownloadUrl,
          mimeType: mimeType,
          fileExtension: originalDownloadUrl.split('.').last.split('?').first,
          estimatedSizeBytes: totalBytes,
          width: width,
          height: height,
          qualityLabel: 'Original',
        ),
      );

      // 2. High Resolution (1920px) if different and available
      if (thumbUrl.isNotEmpty && thumbUrl != originalDownloadUrl) {
        options.add(
          MediaOption(
            id: 'hd_1920',
            label: 'HD Preview (1920px width)',
            downloadUrl: thumbUrl,
            mimeType: mimeType,
            fileExtension: 'jpg',
            estimatedSizeBytes: totalBytes > 0 ? (totalBytes * 0.3).round() : null,
            width: 1920,
            qualityLabel: '1080p / 1920px',
          ),
        );
      }

      return MediaInspectionResult(
        isSupported: true,
        providerName: sourceInfo.displayName,
        title: cleanTitle,
        author: author,
        sourceWebUrl: uri.toString(),
        licenseName: licenseShort,
        licenseUrl: licenseUrl,
        previewThumbnailUrl: thumbUrl.isNotEmpty ? thumbUrl : originalDownloadUrl,
        options: options,
        docReviewRef: sourceInfo.officialDocUrl,
      );
    } catch (e) {
      return MediaInspectionResult.unsupported(
        providerName: sourceInfo.displayName,
        reason: 'Error connecting to Wikimedia API: $e',
        officialAppUrl: uri.toString(),
      );
    }
  }

  static String _stripHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}
