import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_media_downloader/l10n/app_localizations.dart';
import 'package:permission_media_downloader/models/download_item.dart';
import 'package:permission_media_downloader/services/download/file_storage_service.dart';
import 'package:permission_media_downloader/state/download_queue_notifier.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';
import 'package:permission_media_downloader/ui/widgets/empty_state.dart';
import 'package:permission_media_downloader/ui/widgets/provider_badge.dart';
import 'package:provider/provider.dart';

class DownloadsScreen extends StatelessWidget {
  final VoidCallback onNavigateToHome;

  const DownloadsScreen({
    super.key,
    required this.onNavigateToHome,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final queueNotifier = context.watch<DownloadQueueNotifier>();
    final items = queueNotifier.completedItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('downloads_title')),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: l10n.get('clear_completed'),
              onPressed: () => queueNotifier.clearCompleted(),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyStateView(
              icon: Icons.folder_open_rounded,
              title: l10n.get('downloads_empty_title'),
              description: l10n.get('downloads_empty_desc'),
              actionButton: ElevatedButton.icon(
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download Media'),
                onPressed: onNavigateToHome,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _CompletedMediaCard(
                  item: item,
                  onDelete: () => queueNotifier.deleteCompletedFile(item.id),
                );
              },
            ),
    );
  }
}

class _CompletedMediaCard extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback onDelete;

  const _CompletedMediaCard({
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    final formattedDate = item.completedAt != null
        ? DateFormat('MMM dd, yyyy • HH:mm').format(item.completedAt!)
        : 'Saved';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentEmerald.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(mediaIcon, color: AppColors.accentEmerald, size: 24),
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ProviderBadge(
                            providerName: item.sourceProvider,
                            status: SourceSupportStatus.supported,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.formattedTotalSize,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Creator: ${item.author} • ${item.licenseName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date & path info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$formattedDate • ${item.localFilePath != null ? item.localFilePath!.split(RegExp(r'[\\/]')).last : "Stored"}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Actions: Open, Share, Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.accentCoral),
                  tooltip: l10n.get('btn_delete'),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.get('delete_confirm_title')),
                        content: Text(l10n.get('delete_confirm_body')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10n.get('cancel_btn')),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentCoral,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l10n.get('btn_delete')),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      onDelete();
                    }
                  },
                ),

                // Share
                OutlinedButton.icon(
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: Text(l10n.get('btn_share')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (item.localFilePath != null) {
                      await FileStorageService.instance.shareMediaFile(
                        item.localFilePath!,
                        text: '${item.title} (Source: ${item.sourceProvider}, Author: ${item.author})',
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Open
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(l10n.get('btn_open')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (item.localFilePath != null) {
                      final result = await FileStorageService.instance.openMediaFile(item.localFilePath!);
                      if (result.type != ResultType.done && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open file: ${result.message}')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
