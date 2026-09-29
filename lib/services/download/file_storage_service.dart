import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileStorageService {
  static final FileStorageService instance = FileStorageService._internal();

  factory FileStorageService() => instance;

  FileStorageService._internal();

  /// Gets the primary safe directory for saving downloaded media
  Future<Directory> getMediaDirectory() async {
    Directory? dir;
    try {
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
        if (dir != null) {
          final downloadDir = Directory(p.join(dir.path, 'Download'));
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir;
        }
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
        final mediaDir = Directory(p.join(dir.path, 'SavedMedia'));
        if (!await mediaDir.exists()) {
          await mediaDir.create(recursive: true);
        }
        return mediaDir;
      }
    } catch (_) {}

    // Fallback to Application Documents Directory
    final fallback = await getApplicationDocumentsDirectory();
    final mediaFallback = Directory(p.join(fallback.path, 'Downloads'));
    if (!await mediaFallback.exists()) {
      await mediaFallback.create(recursive: true);
    }
    return mediaFallback;
  }

  /// Opens the file with the platform default media viewer
  Future<OpenResult> openMediaFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return OpenResult(
        type: ResultType.fileNotFound,
        message: 'The file does not exist on disk.',
      );
    }
    return OpenFilex.open(filePath);
  }

  /// Shares the file using platform share sheet
  Future<ShareResult> shareMediaFile(String filePath, {String? text}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }
    final xFile = XFile(filePath);
    return Share.shareXFiles([xFile], text: text);
  }

  /// Deletes file from disk
  Future<bool> deleteMediaFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Checks if file exists on disk
  Future<bool> fileExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return false;
    return File(filePath).exists();
  }
}
