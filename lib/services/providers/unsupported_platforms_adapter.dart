import 'package:permission_media_downloader/models/media_option.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/services/providers/base_source_adapter.dart';

class UnsupportedPlatformAdapter extends BaseSourceAdapter {
  final MediaSourceInfo _info;
  final String _unsupportedReason;
  final String _officialAppUrl;

  UnsupportedPlatformAdapter({
    required MediaSourceInfo info,
    required String unsupportedReason,
    required String officialAppUrl,
  })  : _info = info,
        _unsupportedReason = unsupportedReason,
        _officialAppUrl = officialAppUrl;

  @override
  MediaSourceInfo get sourceInfo => _info;

  @override
  Future<MediaInspectionResult> inspectMedia(Uri uri, {String? authToken, String? apiKey}) async {
    return MediaInspectionResult.unsupported(
      providerName: _info.displayName,
      reason: _unsupportedReason,
      officialAppUrl: _officialAppUrl,
      docReviewRef: _info.officialDocUrl,
    );
  }

  // Pre-configured platform policies
  static List<UnsupportedPlatformAdapter> get allKnownUnsupported => [
        // YouTube
        UnsupportedPlatformAdapter(
          info: const MediaSourceInfo(
            id: 'youtube',
            displayName: 'YouTube',
            domainPattern: 'youtube.com, youtu.be',
            matchDomains: ['youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be'],
            allowedDownloadHosts: [],
            supportStatus: SourceSupportStatus.unsupported,
            officialDocUrl: 'https://www.youtube.com/static?template=terms',
            policySummary:
                'YouTube Terms of Service §5.B strictly prohibits accessing, reproducing, or downloading content without express written consent or an official YouTube download button.',
            permittedMethod: 'None for third-party downloader apps',
            requiredScopes: [],
            reviewDate: '2026-09-29',
          ),
          unsupportedReason:
              'YouTube’s Terms of Service (§5.B) prohibit third-party apps from downloading video or audio streams without official permission. To watch videos offline, use the official YouTube mobile app with YouTube Premium.',
          officialAppUrl: 'https://www.youtube.com',
        ),

        // TikTok
        UnsupportedPlatformAdapter(
          info: const MediaSourceInfo(
            id: 'tiktok',
            displayName: 'TikTok',
            domainPattern: 'tiktok.com, *.tiktok.com',
            matchDomains: ['tiktok.com', 'www.tiktok.com', 'vm.tiktok.com', 'vt.tiktok.com', 'm.tiktok.com'],
            allowedDownloadHosts: [],
            supportStatus: SourceSupportStatus.unsupported,
            officialDocUrl: 'https://www.tiktok.com/legal/page/row/terms-of-service/en',
            policySummary:
                'TikTok Terms of Service §5 prohibits scraping, extracting source media, or circumventing platform access controls.',
            permittedMethod: 'None for third-party media downloaders',
            requiredScopes: [],
            reviewDate: '2026-09-29',
          ),
          unsupportedReason:
              'TikTok prohibits third-party downloading and stream extraction. To save videos where allowed by creators, use the official TikTok app’s built-in "Save Video" feature.',
          officialAppUrl: 'https://www.tiktok.com',
        ),

        // Instagram
        UnsupportedPlatformAdapter(
          info: const MediaSourceInfo(
            id: 'instagram',
            displayName: 'Instagram',
            domainPattern: 'instagram.com, instagr.am',
            matchDomains: ['instagram.com', 'www.instagram.com', 'instagr.am'],
            allowedDownloadHosts: [],
            supportStatus: SourceSupportStatus.unsupported,
            officialDocUrl: 'https://help.instagram.com/581066165581870',
            policySummary:
                'Meta Platform Terms & Instagram Terms of Use prohibit scraping, automated data harvesting, or extracting media without authorization.',
            permittedMethod: 'Meta Graph API (user owned media only via explicit Business Login)',
            requiredScopes: ['instagram_basic', 'pages_show_list'],
            reviewDate: '2026-09-29',
          ),
          unsupportedReason:
              'Instagram’s Terms of Use prohibit automated media extraction and third-party link downloading. Please view or save content using the official Instagram app or bookmarks.',
          officialAppUrl: 'https://www.instagram.com',
        ),

        // Facebook
        UnsupportedPlatformAdapter(
          info: const MediaSourceInfo(
            id: 'facebook',
            displayName: 'Facebook',
            domainPattern: 'facebook.com, fb.watch, fb.com',
            matchDomains: ['facebook.com', 'www.facebook.com', 'm.facebook.com', 'fb.watch', 'fb.com'],
            allowedDownloadHosts: [],
            supportStatus: SourceSupportStatus.unsupported,
            officialDocUrl: 'https://www.facebook.com/terms.php',
            policySummary:
                'Facebook Terms of Service §3.2.3 prohibits collecting data using automated means or accessing data without permission.',
            permittedMethod: 'None for general user media links',
            requiredScopes: [],
            reviewDate: '2026-09-29',
          ),
          unsupportedReason:
              'Facebook prohibits unauthorized third-party media downloading. Use official Facebook apps to view content or manage your personal account data via Facebook Settings.',
          officialAppUrl: 'https://www.facebook.com',
        ),

        // X (formerly Twitter)
        UnsupportedPlatformAdapter(
          info: const MediaSourceInfo(
            id: 'twitter',
            displayName: 'X (Twitter)',
            domainPattern: 'twitter.com, x.com',
            matchDomains: ['twitter.com', 'www.twitter.com', 'x.com', 'www.x.com', 't.co'],
            allowedDownloadHosts: [],
            supportStatus: SourceSupportStatus.unsupported,
            officialDocUrl: 'https://twitter.com/en/tos',
            policySummary:
                'X Developer Agreement prohibits scraping or redistributing media streams outside of official timeline display.',
            permittedMethod: 'Official X API v2 (Timeline display only)',
            requiredScopes: ['tweet.read'],
            reviewDate: '2026-09-29',
          ),
          unsupportedReason:
              'X Terms of Service prohibit third-party media extraction tools. Use the official X app or bookmarks to view posts.',
          officialAppUrl: 'https://x.com',
        ),

        // Pinterest
        UnsupportedPlatformAdapter(
          info: const MediaSourceInfo(
            id: 'pinterest',
            displayName: 'Pinterest',
            domainPattern: 'pinterest.com, pin.it',
            matchDomains: ['pinterest.com', 'www.pinterest.com', 'pin.it'],
            allowedDownloadHosts: [],
            supportStatus: SourceSupportStatus.unsupported,
            officialDocUrl: 'https://policy.pinterest.com/en/terms-of-service',
            policySummary:
                'Pinterest Terms of Service prohibit unauthorized extraction of pin assets or bypassing platform interfaces.',
            permittedMethod: 'None for third-party video/image extractors',
            requiredScopes: [],
            reviewDate: '2026-09-29',
          ),
          unsupportedReason:
              'Pinterest Terms of Service prohibit third-party link extractors. Save pins to personal boards directly inside the official Pinterest app.',
          officialAppUrl: 'https://www.pinterest.com',
        ),
      ];
}
