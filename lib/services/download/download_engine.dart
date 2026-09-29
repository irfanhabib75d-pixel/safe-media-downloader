import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:permission_media_downloader/models/download_item.dart';
import 'package:permission_media_downloader/services/security/filename_sanitizer.dart';
import 'package:permission_media_downloader/services/security/url_validator.dart';

typedef ProgressCallback = void Function({
  required int transferredBytes,
  required int totalBytes,
  required double progress,
  required int speedBytesPerSec,
  required int etaSeconds,
});

class DownloadEngine {
  static const int maxFileSizeBytes = 500 * 1024 * 1024; // 500 MB Safe Upper Limit
  static const int bufferChunkSize = 64 * 1024; // 64 KB Stream buffer

  final Map<String, _ActiveTaskContext> _activeTasks = {};

  bool isDownloading(String id) => _activeTasks.containsKey(id);

  /// Start or resume downloading a file
  Future<File> downloadFile({
    required DownloadItem item,
    required String targetDirectoryPath,
    required List<String> allowedHosts,
    required ProgressCallback onProgress,
    int maxRetries = 3,
  }) async {
    final sanitizedFileName = FilenameSanitizer.sanitizeFilename(
      item.title,
      item.fileExtension,
      mimeType: item.mimeType,
    );

    final finalFilePath = p.join(targetDirectoryPath, sanitizedFileName);
    final partFilePath = '$finalFilePath.part';

    final partFile = File(partFilePath);
    var existingBytes = 0;
    if (await partFile.exists()) {
      existingBytes = await partFile.length();
    }

    final taskContext = _ActiveTaskContext(
      id: item.id,
      partFile: partFile,
      targetFile: File(finalFilePath),
    );
    _activeTasks[item.id] = taskContext;

    var attempt = 0;
    while (attempt <= maxRetries) {
      if (taskContext.isCancelled) {
        await _cleanupPartFile(partFile);
        _activeTasks.remove(item.id);
        throw Exception('Download was cancelled by user.');
      }

      if (taskContext.isPaused) {
        _activeTasks.remove(item.id);
        throw Exception('Download was paused.');
      }

      try {
        final downloadedFile = await _executeDownloadStream(
          item: item,
          taskContext: taskContext,
          startByte: existingBytes,
          allowedHosts: allowedHosts,
          onProgress: onProgress,
        );
        _activeTasks.remove(item.id);
        return downloadedFile;
      } catch (e) {
        if (taskContext.isPaused || taskContext.isCancelled) {
          _activeTasks.remove(item.id);
          rethrow;
        }

        attempt++;
        if (attempt > maxRetries) {
          _activeTasks.remove(item.id);
          throw Exception('Download failed after $maxRetries attempts: $e');
        }

        // Exponential backoff wait before retry
        await Future.delayed(Duration(milliseconds: 1000 * attempt));
        if (await partFile.exists()) {
          existingBytes = await partFile.length();
        }
      }
    }

    _activeTasks.remove(item.id);
    throw Exception('Download failed unexpectedly.');
  }

  Future<File> _executeDownloadStream({
    required DownloadItem item,
    required _ActiveTaskContext taskContext,
    required int startByte,
    required List<String> allowedHosts,
    required ProgressCallback onProgress,
  }) async {
    final initialUri = Uri.parse(item.downloadUrl);

    // Validate initial URL host
    if (allowedHosts.isNotEmpty &&
        !UrlValidator.isHostAllowed(initialUri.host, allowedHosts)) {
      throw Exception('Initial download host ${initialUri.host} is not in provider allowlist.');
    }

    final request = http.Request('GET', initialUri);
    request.headers['User-Agent'] =
        'SafeMediaDownloaderApp/1.0 (Authorized Media Downloader; Flutter)';

    if (startByte > 0) {
      request.headers['Range'] = 'bytes=$startByte-';
    }

    final client = http.Client();
    taskContext.httpClient = client;

    final streamedResponse = await client.send(request);

    // Follow redirects safely if any
    if (streamedResponse.isRedirect ||
        streamedResponse.statusCode == 301 ||
        streamedResponse.statusCode == 302 ||
        streamedResponse.statusCode == 307 ||
        streamedResponse.statusCode == 308) {
      final location = streamedResponse.headers['location'];
      if (location == null) {
        throw Exception('Redirect with no location header.');
      }
      final redirectUri = Uri.parse(location);
      if (!UrlValidator.validateDownloadRedirect(redirectUri, allowedHosts)) {
        throw Exception('Redirect to unauthorized host blocked: ${redirectUri.host}');
      }
    }

    // Check status code
    final statusCode = streamedResponse.statusCode;
    final isPartial = statusCode == 206;
    final isFull = statusCode == 200;

    if (!isPartial && !isFull) {
      throw Exception('Server returned HTTP status $statusCode');
    }

    // Content-Type validation
    final contentType = streamedResponse.headers['content-type'] ?? item.mimeType;
    if (contentType.toLowerCase().contains('text/html') ||
        contentType.toLowerCase().contains('application/x-msdownload') ||
        contentType.toLowerCase().contains('application/x-executable')) {
      throw Exception('Security violation: Server returned non-media content-type: $contentType');
    }

    final contentLength = streamedResponse.contentLength ?? 0;
    var totalBytes = isPartial ? (startByte + contentLength) : contentLength;
    if (totalBytes <= 0 && item.totalBytes > 0) {
      totalBytes = item.totalBytes;
    }

    if (totalBytes > maxFileSizeBytes) {
      throw Exception('File exceeds maximum safe download limit of 500 MB.');
    }

    // Open file sink
    final fileMode = (isPartial && startByte > 0) ? FileMode.append : FileMode.write;
    final sink = taskContext.partFile.openWrite(mode: fileMode);
    taskContext.fileSink = sink;

    var currentTransferred = (isPartial && startByte > 0) ? startByte : 0;
    var lastReportTime = DateTime.now();
    var bytesSinceLastReport = 0;
    var currentSpeed = 0;

    final completer = Completer<File>();

    late StreamSubscription<List<int>> subscription;
    subscription = streamedResponse.stream.listen(
      (chunk) {
        if (taskContext.isPaused || taskContext.isCancelled) {
          subscription.cancel();
          return;
        }

        sink.add(chunk);
        currentTransferred += chunk.length;
        bytesSinceLastReport += chunk.length;

        final now = DateTime.now();
        final elapsedMs = now.difference(lastReportTime).inMilliseconds;
        if (elapsedMs >= 500) {
          currentSpeed = ((bytesSinceLastReport * 1000) / elapsedMs).round();
          lastReportTime = now;
          bytesSinceLastReport = 0;

          final progress = totalBytes > 0 ? (currentTransferred / totalBytes).clamp(0.0, 1.0) : 0.0;
          final remainingBytes = totalBytes > currentTransferred ? (totalBytes - currentTransferred) : 0;
          final eta = (currentSpeed > 0 && remainingBytes > 0) ? (remainingBytes / currentSpeed).round() : 0;

          onProgress(
            transferredBytes: currentTransferred,
            totalBytes: totalBytes,
            progress: progress,
            speedBytesPerSec: currentSpeed,
            etaSeconds: eta,
          );
        }
      },
      onDone: () async {
        await sink.flush();
        await sink.close();
        taskContext.fileSink = null;

        if (taskContext.isPaused) {
          completer.completeError(Exception('Download paused.'));
          return;
        }
        if (taskContext.isCancelled) {
          await _cleanupPartFile(taskContext.partFile);
          completer.completeError(Exception('Download cancelled.'));
          return;
        }

        // Rename .part to final file
        if (await taskContext.targetFile.exists()) {
          await taskContext.targetFile.delete();
        }
        final finalFile = await taskContext.partFile.rename(taskContext.targetFile.path);

        onProgress(
          transferredBytes: currentTransferred,
          totalBytes: totalBytes > 0 ? totalBytes : currentTransferred,
          progress: 1.0,
          speedBytesPerSec: 0,
          etaSeconds: 0,
        );

        completer.complete(finalFile);
      },
      onError: (err) async {
        await sink.flush();
        await sink.close();
        taskContext.fileSink = null;
        completer.completeError(err);
      },
      cancelOnError: true,
    );

    taskContext.streamSubscription = subscription;
    return completer.future;
  }

  void pauseDownload(String id) {
    final ctx = _activeTasks[id];
    if (ctx != null) {
      ctx.isPaused = true;
      ctx.streamSubscription?.cancel();
      ctx.httpClient?.close();
      ctx.fileSink?.close();
    }
  }

  void cancelDownload(String id) {
    final ctx = _activeTasks[id];
    if (ctx != null) {
      ctx.isCancelled = true;
      ctx.streamSubscription?.cancel();
      ctx.httpClient?.close();
      ctx.fileSink?.close();
      _cleanupPartFile(ctx.partFile);
    }
  }

  Future<void> _cleanupPartFile(File partFile) async {
    try {
      if (await partFile.exists()) {
        await partFile.delete();
      }
    } catch (_) {}
  }
}

class _ActiveTaskContext {
  final String id;
  final File partFile;
  final File targetFile;
  bool isPaused = false;
  bool isCancelled = false;
  http.Client? httpClient;
  IOSink? fileSink;
  StreamSubscription<List<int>>? streamSubscription;

  _ActiveTaskContext({
    required this.id,
    required this.partFile,
    required this.targetFile,
  });
}
