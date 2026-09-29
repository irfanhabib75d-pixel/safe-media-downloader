import 'package:flutter/material.dart';
import 'package:permission_media_downloader/l10n/app_localizations.dart';
import 'package:permission_media_downloader/models/download_item.dart';
import 'package:permission_media_downloader/state/download_queue_notifier.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';
import 'package:permission_media_downloader/ui/widgets/download_progress_card.dart';
import 'package:permission_media_downloader/ui/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class QueueScreen extends StatelessWidget {
  final VoidCallback onNavigateToHome;

  const QueueScreen({
    super.key,
    required this.onNavigateToHome,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queueNotifier = context.watch<DownloadQueueNotifier>();
    final items = queueNotifier.activeAndQueuedItems;
    final hasActive = items.any((i) => i.status == DownloadStatus.downloading);
    final hasPaused = items.any((i) => i.status == DownloadStatus.paused);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('queue_title')),
        actions: [
          if (hasActive)
            IconButton(
              icon: const Icon(Icons.pause_circle_outline),
              tooltip: l10n.get('pause_all'),
              onPressed: () => queueNotifier.pauseAll(),
            )
          else if (hasPaused)
            IconButton(
              icon: const Icon(Icons.play_circle_outline),
              tooltip: l10n.get('resume_all'),
              onPressed: () => queueNotifier.resumeAll(),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyStateView(
              icon: Icons.hourglass_empty_rounded,
              title: l10n.get('queue_empty_title'),
              description: l10n.get('queue_empty_desc'),
              actionButton: ElevatedButton.icon(
                icon: const Icon(Icons.add_link, size: 18),
                label: const Text('Add Media Link'),
                onPressed: onNavigateToHome,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return DownloadProgressCard(
                  key: ValueKey(item.id),
                  item: item,
                  onPause: () => queueNotifier.pauseDownload(item.id),
                  onResume: () => queueNotifier.resumeDownload(item.id),
                  onCancel: () => queueNotifier.cancelDownload(item.id),
                  onRetry: () => queueNotifier.retryDownload(item.id),
                  onRemove: () => queueNotifier.removeDownload(item.id),
                );
              },
            ),
    );
  }
}
