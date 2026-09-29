import 'dart:convert';

enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

enum MediaTypeCategory {
  image,
  video,
  audio,
  document,
}

class DownloadItem {
  final String id;
  final String originalUrl;
  final String downloadUrl;
  final String title;
  final String sourceProvider;
  final String author;
  final String licenseName;
  final String? licenseUrl;
  final String mimeType;
  final String fileExtension;
  final int totalBytes;
  final int transferredBytes;
  final double progress; // 0.0 to 1.0
  final int speedBytesPerSec;
  final int etaSeconds;
  final DownloadStatus status;
  final String? localFilePath;
  final String? errorReason;
  final DateTime createdAt;
  final DateTime? completedAt;

  DownloadItem({
    required this.id,
    required this.originalUrl,
    required this.downloadUrl,
    required this.title,
    required this.sourceProvider,
    required this.author,
    required this.licenseName,
    this.licenseUrl,
    required this.mimeType,
    required this.fileExtension,
    this.totalBytes = 0,
    this.transferredBytes = 0,
    this.progress = 0.0,
    this.speedBytesPerSec = 0,
    this.etaSeconds = 0,
    this.status = DownloadStatus.queued,
    this.localFilePath,
    this.errorReason,
    required this.createdAt,
    this.completedAt,
  });

  MediaTypeCategory get mediaTypeCategory {
    final lower = mimeType.toLowerCase();
    if (lower.startsWith('video/')) return MediaTypeCategory.video;
    if (lower.startsWith('audio/')) return MediaTypeCategory.audio;
    if (lower.startsWith('image/')) return MediaTypeCategory.image;
    return MediaTypeCategory.document;
  }

  DownloadItem copyWith({
    String? id,
    String? originalUrl,
    String? downloadUrl,
    String? title,
    String? sourceProvider,
    String? author,
    String? licenseName,
    String? licenseUrl,
    String? mimeType,
    String? fileExtension,
    int? totalBytes,
    int? transferredBytes,
    double? progress,
    int? speedBytesPerSec,
    int? etaSeconds,
    DownloadStatus? status,
    String? localFilePath,
    String? errorReason,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      originalUrl: originalUrl ?? this.originalUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      title: title ?? this.title,
      sourceProvider: sourceProvider ?? this.sourceProvider,
      author: author ?? this.author,
      licenseName: licenseName ?? this.licenseName,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      mimeType: mimeType ?? this.mimeType,
      fileExtension: fileExtension ?? this.fileExtension,
      totalBytes: totalBytes ?? this.totalBytes,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      progress: progress ?? this.progress,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      status: status ?? this.status,
      localFilePath: localFilePath ?? this.localFilePath,
      errorReason: errorReason ?? this.errorReason,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalUrl': originalUrl,
      'downloadUrl': downloadUrl,
      'title': title,
      'sourceProvider': sourceProvider,
      'author': author,
      'licenseName': licenseName,
      'licenseUrl': licenseUrl,
      'mimeType': mimeType,
      'fileExtension': fileExtension,
      'totalBytes': totalBytes,
      'transferredBytes': transferredBytes,
      'progress': progress,
      'status': status.name,
      'localFilePath': localFilePath,
      'errorReason': errorReason,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'] as String,
      originalUrl: json['originalUrl'] as String,
      downloadUrl: json['downloadUrl'] as String,
      title: json['title'] as String,
      sourceProvider: json['sourceProvider'] as String,
      author: json['author'] as String? ?? 'Unknown Creator',
      licenseName: json['licenseName'] as String? ?? 'Authorized License',
      licenseUrl: json['licenseUrl'] as String?,
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      fileExtension: json['fileExtension'] as String? ?? 'dat',
      totalBytes: json['totalBytes'] as int? ?? 0,
      transferredBytes: json['transferredBytes'] as int? ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.completed,
      ),
      localFilePath: json['localFilePath'] as String?,
      errorReason: json['errorReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  String get formattedTransferredSize => _formatBytes(transferredBytes);
  String get formattedTotalSize =>
      totalBytes > 0 ? _formatBytes(totalBytes) : 'Unknown';
  String get formattedSpeed =>
      speedBytesPerSec > 0 ? '${_formatBytes(speedBytesPerSec)}/s' : '--';

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
