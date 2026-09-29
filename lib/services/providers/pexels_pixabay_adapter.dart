import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_media_downloader/models/media_option.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/services/providers/base_source_adapter.dart';

class PexelsAdapter extends BaseSourceAdapter {
  static const String defaultPexelsApiKey = '563492ad6f91700001000001a1b2c3d4e5f6g7h8i9j0';

  @override
  MediaSourceInfo get sourceInfo => const MediaSourceInfo(
        id: 'pexels',
        displayName: 'Pexels',
        domainPattern: 'pexels.com, *.pexels.com',
        matchDomains: ['pexels.com', 'www.pexels.com'],
        allowedDownloadHosts: ['images.pexels.com', 'videos.pexels.com', '*.pexels.com'],
        supportStatus: SourceSupportStatus.supported,
        officialDocUrl: 'https://www.pexels.com/api/documentation/',
        policySummary:
            'Pexels API explicitly authorizes downloading full-resolution photos & videos under the free-to-use Pexels License.',
        permittedMethod: 'Official Pexels REST API (/v1/photos/{id} & /videos/videos/{id})',
        requiredScopes: [],
        reviewDate: '2026-09-29',
        requiresOAuth: false,
      );

  @override
  Future<MediaInspectionResult> inspectMedia(Uri uri, {String? authToken, String? apiKey}) async {
    try {
      final segments = uri.pathSegments;
      final isVideo = segments.contains('video') || segments.contains('videos');

      // Extract numeric ID from URL: e.g. /photo/title-123456/ or /video/title-123456/
      String? mediaId;
      for (final seg in segments.reversed) {
        final match = RegExp(r'(\d+)$').firstMatch(seg);
        if (match != null) {
          mediaId = match.group(1);
          break;
        }
      }

      if (mediaId == null) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Could not extract a valid Pexels photo or video ID from the link.',
          officialAppUrl: uri.toString(),
        );
      }

      final key = (apiKey != null && apiKey.isNotEmpty) ? apiKey : defaultPexelsApiKey;
      final endpoint = isVideo
          ? 'https://api.pexels.com/videos/videos/$mediaId'
          : 'https://api.pexels.com/v1/photos/$mediaId';

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': key,
          'User-Agent': 'SafeMediaDownloader/1.0',
        },
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Pexels API requires an active API key. Please configure your Pexels key in Settings.',
          officialAppUrl: uri.toString(),
        );
      }

      if (response.statusCode != 200) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Pexels API returned HTTP ${response.statusCode}',
          officialAppUrl: uri.toString(),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final options = <MediaOption>[];

      if (isVideo) {
        final videoFiles = (data['video_files'] as List<dynamic>?) ?? [];
        final user = data['user'] as Map<String, dynamic>?;
        final author = user?['name'] as String? ?? 'Pexels Videographer';
        final duration = data['duration'] as int? ?? 0;

        for (final vf in videoFiles) {
          final fileObj = vf as Map<String, dynamic>;
          final link = fileObj['link'] as String? ?? '';
          final quality = fileObj['quality'] as String? ?? 'hd';
          final width = fileObj['width'] as int?;
          final height = fileObj['height'] as int?;
          final fileType = fileObj['file_type'] as String? ?? 'video/mp4';

          if (link.isNotEmpty) {
            options.add(
              MediaOption(
                id: 'video_${quality}_${width ?? 0}',
                label: '${quality.toUpperCase()} (${width != null && height != null ? "${width}x$height" : ""})',
                downloadUrl: link,
                mimeType: fileType,
                fileExtension: 'mp4',
                width: width,
                height: height,
                qualityLabel: quality,
              ),
            );
          }
        }

        final pictures = (data['video_pictures'] as List<dynamic>?) ?? [];
        final thumb = pictures.isNotEmpty ? (pictures.first['picture'] as String?) : null;

        return MediaInspectionResult(
          isSupported: true,
          providerName: sourceInfo.displayName,
          title: 'Pexels Video #$mediaId (${duration}s)',
          author: author,
          sourceWebUrl: uri.toString(),
          licenseName: 'Pexels License (Free to use, attribution appreciated)',
          previewThumbnailUrl: thumb,
          options: options,
          docReviewRef: sourceInfo.officialDocUrl,
        );
      } else {
        final src = data['src'] as Map<String, dynamic>? ?? {};
        final photographer = data['photographer'] as String? ?? 'Pexels Photographer';
        final alt = data['alt'] as String? ?? 'Pexels Photo #$mediaId';
        final original = src['original'] as String? ?? '';
        final large2x = src['large2x'] as String? ?? '';
        final large = src['large'] as String? ?? '';
        final medium = src['medium'] as String? ?? '';

        if (original.isNotEmpty) {
          options.add(
            MediaOption(
              id: 'original',
              label: 'Original Full Resolution (${data['width']}x${data['height']})',
              downloadUrl: original,
              mimeType: 'image/jpeg',
              fileExtension: 'jpg',
              width: data['width'] as int?,
              height: data['height'] as int?,
              qualityLabel: 'Original',
            ),
          );
        }

        if (large2x.isNotEmpty) {
          options.add(
            MediaOption(
              id: 'large2x',
              label: 'Ultra HD (Large 2x)',
              downloadUrl: large2x,
              mimeType: 'image/jpeg',
              fileExtension: 'jpg',
              qualityLabel: '2K / QHD',
            ),
          );
        }

        if (large.isNotEmpty) {
          options.add(
            MediaOption(
              id: 'large',
              label: 'HD (Large)',
              downloadUrl: large,
              mimeType: 'image/jpeg',
              fileExtension: 'jpg',
              qualityLabel: 'HD',
            ),
          );
        }

        return MediaInspectionResult(
          isSupported: true,
          providerName: sourceInfo.displayName,
          title: alt.isNotEmpty ? alt : 'Pexels Photo #$mediaId',
          author: photographer,
          sourceWebUrl: uri.toString(),
          licenseName: 'Pexels License (Free to use, attribution appreciated)',
          previewThumbnailUrl: medium.isNotEmpty ? medium : original,
          options: options,
          docReviewRef: sourceInfo.officialDocUrl,
        );
      }
    } catch (e) {
      return MediaInspectionResult.unsupported(
        providerName: sourceInfo.displayName,
        reason: 'Error querying Pexels official API: $e',
        officialAppUrl: uri.toString(),
      );
    }
  }
}
