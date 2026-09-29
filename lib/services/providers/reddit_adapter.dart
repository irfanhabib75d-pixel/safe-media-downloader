import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_media_downloader/models/media_option.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/services/providers/base_source_adapter.dart';

class RedditAdapter extends BaseSourceAdapter {
  @override
  MediaSourceInfo get sourceInfo => const MediaSourceInfo(
        id: 'reddit',
        displayName: 'Reddit',
        domainPattern: 'reddit.com, redd.it, i.redd.it, v.redd.it',
        matchDomains: ['reddit.com', 'www.reddit.com', 'redd.it', 'i.redd.it', 'v.redd.it'],
        allowedDownloadHosts: ['i.redd.it', 'v.redd.it', 'preview.redd.it', 'external-preview.redd.it'],
        supportStatus: SourceSupportStatus.supported,
        officialDocUrl: 'https://www.reddit.com/dev/api/',
        policySummary:
            'Reddit API provides structured post metadata for public author-uploaded media links (i.redd.it).',
        permittedMethod: 'Official Reddit Public Endpoint (/comments/{id}.json)',
        requiredScopes: ['read'],
        reviewDate: '2026-09-29',
        requiresOAuth: false,
      );

  @override
  Future<MediaInspectionResult> inspectMedia(Uri uri, {String? authToken, String? apiKey}) async {
    try {
      // Direct i.redd.it direct image link
      if (uri.host.toLowerCase() == 'i.redd.it') {
        final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'reddit_image.jpg';
        final ext = fileName.split('.').last.toLowerCase();
        final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

        return MediaInspectionResult(
          isSupported: true,
          providerName: sourceInfo.displayName,
          title: 'Reddit Direct Image ($fileName)',
          author: 'Reddit Author',
          sourceWebUrl: uri.toString(),
          licenseName: 'Author-published Media',
          previewThumbnailUrl: uri.toString(),
          options: [
            MediaOption(
              id: 'direct_image',
              label: 'Original Image ($ext)',
              downloadUrl: uri.toString(),
              mimeType: mimeType,
              fileExtension: ext,
              qualityLabel: 'Original',
            ),
          ],
          docReviewRef: sourceInfo.officialDocUrl,
        );
      }

      // Extract Post ID from Reddit post URL: e.g. /r/{sub}/comments/{id}/...
      String? postId;
      if (uri.pathSegments.contains('comments')) {
        final idx = uri.pathSegments.indexOf('comments');
        if (idx + 1 < uri.pathSegments.length) {
          postId = uri.pathSegments[idx + 1];
        }
      } else if (uri.host.toLowerCase() == 'redd.it' && uri.pathSegments.isNotEmpty) {
        postId = uri.pathSegments.first;
      }

      if (postId == null || postId.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Could not extract Reddit post ID from the URL.',
          officialAppUrl: uri.toString(),
        );
      }

      // Query official JSON endpoint with custom user agent
      final apiUrl = Uri.parse('https://www.reddit.com/comments/$postId.json');
      final response = await http.get(
        apiUrl,
        headers: {
          'User-Agent': 'SafeMediaDownloaderApp/1.0 (by /u/SafeMediaDownloader)',
        },
      );

      if (response.statusCode != 200) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Reddit API returned HTTP ${response.statusCode}',
          officialAppUrl: uri.toString(),
        );
      }

      final dataList = json.decode(response.body) as List<dynamic>;
      if (dataList.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'No post data returned by Reddit API.',
        );
      }

      final postObj = dataList.first['data']?['children']?[0]?['data'] as Map<String, dynamic>?;
      if (postObj == null) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Invalid Reddit post payload.',
        );
      }

      final title = postObj['title'] as String? ?? 'Reddit Post';
      final author = postObj['author'] as String? ?? 'Reddit User';
      final mediaUrl = postObj['url'] as String? ?? '';
      final isVideo = postObj['is_video'] as bool? ?? false;
      final over18 = postObj['over_18'] as bool? ?? false;

      if (mediaUrl.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'This Reddit post does not contain any author-hosted media file.',
          officialAppUrl: uri.toString(),
        );
      }

      final options = <MediaOption>[];

      if (isVideo) {
        final secureMedia = postObj['secure_media'] as Map<String, dynamic>?;
        final redditVideo = secureMedia?['reddit_video'] as Map<String, dynamic>?;
        final fallbackUrl = redditVideo?['fallback_url'] as String? ?? '';

        if (fallbackUrl.isNotEmpty) {
          options.add(
            MediaOption(
              id: 'reddit_video',
              label: 'Video Stream (${redditVideo?['height']}p)',
              downloadUrl: fallbackUrl,
              mimeType: 'video/mp4',
              fileExtension: 'mp4',
              height: redditVideo?['height'] as int?,
              width: redditVideo?['width'] as int?,
              qualityLabel: '${redditVideo?['height']}p',
            ),
          );
        }
      } else if (mediaUrl.contains('i.redd.it') || mediaUrl.contains('.jpg') || mediaUrl.contains('.png') || mediaUrl.contains('.gif')) {
        final ext = mediaUrl.split('.').last.split('?').first.toLowerCase();
        options.add(
          MediaOption(
            id: 'reddit_image',
            label: 'Image ($ext)',
            downloadUrl: mediaUrl,
            mimeType: ext == 'png' ? 'image/png' : 'image/jpeg',
            fileExtension: ext,
            qualityLabel: 'Original',
          ),
        );
      }

      if (options.isEmpty) {
        return MediaInspectionResult.unsupported(
          providerName: sourceInfo.displayName,
          reason: 'Post media is hosted on external third-party site or unsupported format.',
          officialAppUrl: uri.toString(),
        );
      }

      return MediaInspectionResult(
        isSupported: true,
        providerName: sourceInfo.displayName,
        title: title,
        author: 'u/$author',
        sourceWebUrl: uri.toString(),
        licenseName: 'Author Post Media',
        previewThumbnailUrl: postObj['thumbnail'] as String?,
        options: options,
        docReviewRef: sourceInfo.officialDocUrl,
      );
    } catch (e) {
      return MediaInspectionResult.unsupported(
        providerName: sourceInfo.displayName,
        reason: 'Error connecting to Reddit API: $e',
        officialAppUrl: uri.toString(),
      );
    }
  }
}
