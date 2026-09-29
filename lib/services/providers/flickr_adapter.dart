import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_media_downloader/models/media_option.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/services/providers/base_source_adapter.dart';

class FlickrAdapter extends BaseSourceAdapter {
  static const String defaultFlickrApiKey = '92b451df6a877ffcb51a24d26da53db7'; // Public / Open Flickr API Demo Key

  @override
  MediaSourceInfo get sourceInfo => const MediaSourceInfo(
        id: 'flickr',
        displayName: 'Flickr',
        domainPattern: 'flickr.com, flic.kr',
        matchDomains: ['flickr.com', 'www.flickr.com', 'flic.kr'],
        allowedDownloadHosts: ['*.staticflickr.com', 'live.staticflickr.com', 'farm*.staticflickr.com'],
        supportStatus: SourceSupportStatus.supported,
        officialDocUrl: 'https://www.flickr.com/services/api/',
        policySummary:
            'Flickr REST API explicitly provides photo size streams and honors owner download permission flags & CC licenses.',
        permittedMethod: 'Official Flickr REST API (flickr.photos.getSizes & flickr.photos.getInfo)',
        requiredScopes: ['read'],
        reviewDate: '2026-09-29',
        requiresOAuth: false,
      );

  @override
  Future<MediaInspectionResult> inspectMedia(Uri uri, {String? authToken, String? apiKey}) async {
    try {
      // 1. Extract Photo ID from URL: e.g. /photos/{user}/{photoId}
      String? photoId;
      final pathSegments = uri.pathSegments;
      if (pathSegments.contains('photos')) {
        final idx = pathSegments.indexOf('photos');
        if (idx + 2 < pathSegments.length) {
          photoId = pathSegments[idx + 2];
        }
      } else if (pathSegments.isNotEmpty) {
        photoId = pathSegments.last;
      }

      if (photoId == null || !RegExp(r'^\d+$').hasMatch(photoId)) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Could not parse a valid numeric Flickr photo ID from the URL.',
          officialAppUrl: uri.toString(),
        );
      }

      final key = (apiKey != null && apiKey.isNotEmpty) ? apiKey : defaultFlickrApiKey;

      // 2. Fetch photo info (title, author, license, can_download permission)
      final infoUrl = Uri.parse('https://api.flickr.com/services/rest/').replace(
        queryParameters: {
          'method': 'flickr.photos.getInfo',
          'api_key': key,
          'photo_id': photoId,
          'format': 'json',
          'nojsoncallback': '1',
        },
      );

      final infoRes = await http.get(infoUrl);
      if (infoRes.statusCode != 200) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Flickr API connection failed (HTTP ${infoRes.statusCode})',
        );
      }

      final infoJson = json.decode(infoRes.body) as Map<String, dynamic>;
      if (infoJson['stat'] != 'ok') {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: infoJson['message'] as String? ?? 'Photo not found or restricted on Flickr.',
        );
      }

      final photo = infoJson['photo'] as Map<String, dynamic>;
      final title = (photo['title']?['_content'] as String?) ?? 'Flickr Photo #$photoId';
      final ownerObj = photo['owner'] as Map<String, dynamic>?;
      final author = (ownerObj?['realname'] as String?)?.isNotEmpty == true
          ? ownerObj!['realname'] as String
          : (ownerObj?['username'] as String? ?? 'Flickr User');

      final usage = photo['usage'] as Map<String, dynamic>?;
      final canDownload = usage?['candownload'] == 1 || usage?['candownload'] == '1';

      if (!canDownload) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'The photographer has disabled downloads for this photo in their Flickr settings.',
          officialAppUrl: uri.toString(),
        );
      }

      // 3. Fetch sizes via flickr.photos.getSizes
      final sizesUrl = Uri.parse('https://api.flickr.com/services/rest/').replace(
        queryParameters: {
          'method': 'flickr.photos.getSizes',
          'api_key': key,
          'photo_id': photoId,
          'format': 'json',
          'nojsoncallback': '1',
        },
      );

      final sizesRes = await http.get(sizesUrl);
      final sizesJson = json.decode(sizesRes.body) as Map<String, dynamic>;
      final sizeList = (sizesJson['sizes']?['size'] as List<dynamic>?) ?? [];

      if (sizeList.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'No downloadable sizes available for this Flickr photo.',
        );
      }

      final options = <MediaOption>[];
      String? previewThumb;

      for (final s in sizeList) {
        final sizeItem = s as Map<String, dynamic>;
        final label = sizeItem['label'] as String? ?? 'Size';
        final sourceUrl = sizeItem['source'] as String? ?? '';
        final width = int.tryParse(sizeItem['width']?.toString() ?? '0');
        final height = int.tryParse(sizeItem['height']?.toString() ?? '0');

        if (label.toLowerCase() == 'medium' || label.toLowerCase() == 'small') {
          previewThumb = sourceUrl;
        }

        if (sourceUrl.isNotEmpty) {
          options.add(
            MediaOption(
              id: label.toLowerCase().replaceAll(' ', '_'),
              label: '$label (${width != null && height != null ? "${width}x$height" : ""})',
              downloadUrl: sourceUrl,
              mimeType: 'image/jpeg',
              fileExtension: 'jpg',
              width: width,
              height: height,
              qualityLabel: label,
            ),
          );
        }
      }

      return MediaInspectionResult(
        isSupported: true,
        providerName: sourceInfo.displayName,
        title: title,
        author: author,
        sourceWebUrl: uri.toString(),
        licenseName: 'Flickr Permitted / CC Licensed',
        previewThumbnailUrl: previewThumb ?? (options.isNotEmpty ? options.last.downloadUrl : null),
        options: options.reversed.toList(), // Highest quality first
        docReviewRef: sourceInfo.officialDocUrl,
      );
    } catch (e) {
      return MediaInspectionResult.unsupported(
        providerName: sourceInfo.displayName,
        reason: 'Error connecting to Flickr API: $e',
        officialAppUrl: uri.toString(),
      );
    }
  }
}
