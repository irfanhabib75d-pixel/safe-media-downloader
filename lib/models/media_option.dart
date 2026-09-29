class MediaOption {
  final String id;
  final String label;
  final String downloadUrl;
  final String mimeType;
  final String fileExtension;
  final int? estimatedSizeBytes;
  final int? width;
  final int? height;
  final String? qualityLabel;

  const MediaOption({
    required this.id,
    required this.label,
    required this.downloadUrl,
    required this.mimeType,
    required this.fileExtension,
    this.estimatedSizeBytes,
    this.width,
    this.height,
    this.qualityLabel,
  });

  String get formattedSize {
    if (estimatedSizeBytes == null || estimatedSizeBytes! <= 0) {
      return 'Unknown size';
    }
    final bytes = estimatedSizeBytes!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get resolutionDisplay {
    if (width != null && height != null && width! > 0 && height! > 0) {
      return '${width}x$height';
    }
    return qualityLabel ?? label;
  }
}

class MediaInspectionResult {
  final bool isSupported;
  final String providerName;
  final String title;
  final String author;
  final String? sourceWebUrl;
  final String licenseName;
  final String? licenseUrl;
  final String? previewThumbnailUrl;
  final List<MediaOption> options;
  final String? unsupportedReason;
  final String? suggestedOfficialAppUrl;
  final String? docReviewRef;

  const MediaInspectionResult({
    required this.isSupported,
    required this.providerName,
    this.title = '',
    this.author = 'Unknown Author',
    this.sourceWebUrl,
    this.licenseName = 'Unknown License',
    this.licenseUrl,
    this.previewThumbnailUrl,
    this.options = const [],
    this.unsupportedReason,
    this.suggestedOfficialAppUrl,
    this.docReviewRef,
  });

  factory MediaInspectionResult.unsupported({
    required String providerName,
    required String reason,
    String? officialAppUrl,
    String? docReviewRef,
  }) {
    return MediaInspectionResult(
      isSupported: false,
      providerName: providerName,
      unsupportedReason: reason,
      suggestedOfficialAppUrl: officialAppUrl,
      docReviewRef: docReviewRef,
    );
  }
}
