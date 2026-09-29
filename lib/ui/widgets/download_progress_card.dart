import 'package:flutter/material.dart';
import 'package:permission_media_downloader/l10n/app_localizations.dart';
import 'package:permission_media_downloader/models/download_item.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';

class DownloadProgressCard extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  const DownloadProgressCard({
    super.key,
    required this.item,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onRetry,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    String statusText;
    IconData mediaIcon;

    switch (item.mediaTypeCategory) {
      case MediaTypeCategory.video:
        mediaIcon = Icons.movie_outlined;
        break;
      case MediaTypeCategory.audio:
        mediaIcon = Icons.audiotrack_outlined;
        break;
      case MediaTypeCategory.image:
        mediaIcon = Icons.image_outlined;
        break;
      default:
        mediaIcon = Icons.insert_drive_file_outlined;
    }

    switch (item.status) {
      case DownloadStatus.downloading:
        statusColor = AppColors.primaryBlue;
        statusText = l10n.get('status_downloading');
        break;
      case DownloadStatus.paused:
        statusColor = AppColors.accentAmber;
        statusText = l10n.get('status_paused');
        break;
      case DownloadStatus.queued:
        statusColor = AppColors.accentViolet;
        statusText = l10n.get('status_queued');
        break;
      case DownloadStatus.completed:
        statusColor = AppColors.accentEmerald;
        statusText = l10n.get('status_completed');
        break;
      case DownloadStatus.failed:
        statusColor = AppColors.accentCoral;
        statusText = l10n.get('status_failed');
        break;
      case DownloadStatus.cancelled:
        statusColor = Colors.grey;
        statusText = l10n.get('status_cancelled');
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with icon, title, provider
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(mediaIcon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            item.sourceProvider,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(' • ', style: TextStyle(color: Colors.grey)),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action button depending on status
                if (item.status == DownloadStatus.downloading)
                  IconButton(
                    icon: const Icon(Icons.pause_circle_outline, color: AppColors.accentAmber),
                    tooltip: l10n.get('btn_pause'),
                    onPressed: onPause,
                  )
                else if (item.status == DownloadStatus.paused)
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline, color: AppColors.primaryBlue),
                    tooltip: l10n.get('btn_resume'),
                    onPressed: onResume,
                  )
                else if (item.status == DownloadStatus.failed)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.accentCoral),
                    tooltip: l10n.get('btn_retry'),
                    onPressed: onRetry,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    tooltip: l10n.get('btn_remove'),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.status == DownloadStatus.queued ? null : item.progress,
                backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),

            // Metrics row: Size, Progress %, Speed, ETA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.formattedTransferredSize} / ${item.formattedTotalSize}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                if (item.status == DownloadStatus.downloading && item.speedBytesPerSec > 0)
                  Text(
                    '⚡ ${item.formattedSpeed}  •  ETA: ${item.etaSeconds}s',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  )
                else if (item.status == DownloadStatus.failed && item.errorReason != null)
                  Expanded(
                    child: Text(
                      item.errorReason!,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.accentCoral),
                    ),
                  )
                else
                  Text(
                    '${(item.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
