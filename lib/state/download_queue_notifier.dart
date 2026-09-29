import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_media_downloader/models/download_item.dart';
import 'package:permission_media_downloader/services/download/download_engine.dart';
import 'package:permission_media_downloader/services/download/file_storage_service.dart';
import 'package:permission_media_downloader/services/history/download_history_service.dart';
import 'package:permission_media_downloader/services/notification/notification_service.dart';
import 'package:permission_media_downloader/services/providers/source_registry.dart';

class DownloadQueueNotifier extends ChangeNotifier {
  final DownloadEngine _engine = DownloadEngine();
  final FileStorageService _storageService = FileStorageService.instance;
  final DownloadHistoryService _historyService = DownloadHistoryService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  final List<DownloadItem> _items = [];
  final Set<String> _activeItemIds = {};
  static const int _maxConcurrent = 2;

  List<DownloadItem> get allItems => List.unmodifiable(_items);

  List<DownloadItem> get activeAndQueuedItems => _items
      .where((i) =>
          i.status == DownloadStatus.downloading ||
          i.status == DownloadStatus.queued ||
          i.status == DownloadStatus.paused ||
          i.status == DownloadStatus.failed)
      .toList();

  List<DownloadItem> get completedItems =>
      _items.where((i) => i.status == DownloadStatus.completed).toList();

  Future<void> loadSavedHistory() async {
    final saved = await _historyService.loadHistory();
    _items.clear();
    _items.addAll(saved);
    notifyListeners();
  }

  Future<void> enqueueDownload(DownloadItem item) async {
    // Add to queue
    _items.removeWhere((i) => i.id == item.id);
    _items.insert(0, item);
    notifyListeners();

    await _historyService.saveHistoryItem(item);
    _processQueue();
  }

  void pauseDownload(String id) {
    _engine.pauseDownload(id);
    _updateItemStatus(id, DownloadStatus.paused);
    _activeItemIds.remove(id);
    _processQueue();
  }

  void resumeDownload(String id) {
    _updateItemStatus(id, DownloadStatus.queued);
    _processQueue();
  }

  void retryDownload(String id) {
    _updateItemStatus(id, DownloadStatus.queued, clearError: true);
    _processQueue();
  }

  void cancelDownload(String id) {
    _engine.cancelDownload(id);
    _activeItemIds.remove(id);
    _updateItemStatus(id, DownloadStatus.cancelled);
    _notificationService.cancelNotification(id.hashCode);
    _processQueue();
  }

  Future<void> removeDownload(String id) async {
    cancelDownload(id);
    _items.removeWhere((i) => i.id == id);
    await _historyService.removeHistoryItem(id);
    notifyListeners();
  }

  void pauseAll() {
    for (final item in _items) {
      if (item.status == DownloadStatus.downloading ||
          item.status == DownloadStatus.queued) {
        pauseDownload(item.id);
      }
    }
  }

  void resumeAll() {
    for (final item in _items) {
      if (item.status == DownloadStatus.paused) {
        resumeDownload(item.id);
      }
    }
  }

  void clearCompleted() {
    _items.removeWhere((i) => i.status == DownloadStatus.completed);
    notifyListeners();
  }

  Future<void> deleteCompletedFile(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      final item = _items[idx];
      if (item.localFilePath != null) {
        await _storageService.deleteMediaFile(item.localFilePath!);
      }
      _items.removeAt(idx);
      await _historyService.removeHistoryItem(id);
      notifyListeners();
    }
  }

  void _updateItemStatus(String id, DownloadStatus status, {bool clearError = false}) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        status: status,
        errorReason: clearError ? null : _items[idx].errorReason,
      );
      notifyListeners();
    }
  }

  void _processQueue() {
    if (_activeItemIds.length >= _maxConcurrent) return;

    final nextItem = _items.firstWhere(
      (i) => i.status == DownloadStatus.queued && !_activeItemIds.contains(i.id),
      orElse: () => DownloadItem(
        id: '',
        originalUrl: '',
        downloadUrl: '',
        title: '',
        sourceProvider: '',
        author: '',
        licenseName: '',
        mimeType: '',
        fileExtension: '',
        createdAt: DateTime.now(),
      ),
    );

    if (nextItem.id.isNotEmpty) {
      _startDownloadTask(nextItem);
    }
  }

  Future<void> _startDownloadTask(DownloadItem item) async {
    _activeItemIds.add(item.id);
    _updateItemStatus(item.id, DownloadStatus.downloading);

    // Resolve allowed hosts from source adapter
    final adapter = SourceRegistry.instance
        .allSupportedAdapters
        .where((a) => a.sourceInfo.displayName == item.sourceProvider)
        .firstOrNull;

    final allowedHosts = adapter?.allowedDownloadHosts ?? [];

    try {
      final targetDir = await _storageService.getMediaDirectory();

      final downloadedFile = await _engine.downloadFile(
        item: item,
        targetDirectoryPath: targetDir.path,
        allowedHosts: allowedHosts,
        onProgress: ({
          required int transferredBytes,
          required int totalBytes,
          required double progress,
          required int speedBytesPerSec,
          required int etaSeconds,
        }) {
          final idx = _items.indexWhere((i) => i.id == item.id);
          if (idx >= 0) {
            _items[idx] = _items[idx].copyWith(
              transferredBytes: transferredBytes,
              totalBytes: totalBytes,
              progress: progress,
              speedBytesPerSec: speedBytesPerSec,
              etaSeconds: etaSeconds,
              status: DownloadStatus.downloading,
            );
            notifyListeners();

            // Notify system tray / lock screen
            _notificationService.showDownloadProgress(
              id: item.id.hashCode,
              title: item.title,
              progressPercent: (progress * 100).round(),
              statusText:
                  '${(progress * 100).toStringAsFixed(0)}% • ${item.formattedSpeed}',
            );
          }
        },
      );

      // Successfully finished
      _activeItemIds.remove(item.id);
      final completedItem = item.copyWith(
        status: DownloadStatus.completed,
        localFilePath: downloadedFile.path,
        progress: 1.0,
        speedBytesPerSec: 0,
        etaSeconds: 0,
        completedAt: DateTime.now(),
      );

      final idx = _items.indexWhere((i) => i.id == item.id);
      if (idx >= 0) {
        _items[idx] = completedItem;
      }
      notifyListeners();

      await _historyService.saveHistoryItem(completedItem);
      await _notificationService.showDownloadCompleted(
        id: item.id.hashCode,
        title: item.title,
        filePath: downloadedFile.path,
      );
    } catch (e) {
      _activeItemIds.remove(item.id);
      final idx = _items.indexWhere((i) => i.id == item.id);
      if (idx >= 0) {
        final current = _items[idx];
        if (current.status != DownloadStatus.paused &&
            current.status != DownloadStatus.cancelled) {
          _items[idx] = current.copyWith(
            status: DownloadStatus.failed,
            errorReason: e.toString().replaceAll('Exception: ', ''),
            speedBytesPerSec: 0,
          );
        }
      }
      notifyListeners();
    } finally {
      _processQueue();
    }
  }
}
