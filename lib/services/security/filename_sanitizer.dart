import 'package:path/path.dart' as p;

class FilenameSanitizer {
  // Allowed safe media extensions
  static const Set<String> _allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'svg',
    'mp4',
    'm4v',
    'webm',
    'mov',
    'mp3',
    'ogg',
    'oga',
    'flac',
    'wav',
    'm4a',
    'pdf',
  };

  // Disallowed dangerous extensions
  static const Set<String> _disallowedExtensions = {
    'exe',
    'bat',
    'cmd',
    'sh',
    'bash',
    'apk',
    'aab',
    'dex',
    'ipa',
    'dll',
    'so',
    'dylib',
    'js',
    'mjs',
    'vbs',
    'ps1',
    'msi',
    'com',
    'scr',
    'pif',
    'jar',
    'bin',
  };

  static String sanitizeFilename(String rawTitle, String fallbackExt, {String? mimeType}) {
    // 1. Resolve safe extension
    var ext = fallbackExt.toLowerCase().replaceAll('.', '').trim();
    if (ext.isEmpty || _disallowedExtensions.contains(ext) || !_allowedExtensions.contains(ext)) {
      ext = _inferExtensionFromMime(mimeType) ?? 'dat';
    }

    // 2. Strip path traversal elements and control characters
    var clean = rawTitle
        .replaceAll(RegExp(r'[\r\n\t\x00-\x1F\x7F]'), '') // Control characters
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_') // Windows & Unix illegal chars
        .replaceAll(RegExp(r'\.\.+'), '_') // Path traversal attempts (..)
        .replaceAll(RegExp(r'^\.+'), '') // Hidden file prefixes
        .trim();

    if (clean.isEmpty) {
      clean = 'media_${DateTime.now().millisecondsSinceEpoch}';
    }

    // 3. Limit length to 100 characters to prevent filesystem overflow
    if (clean.length > 100) {
      clean = clean.substring(0, 100).trim();
    }

    // Ensure it doesn't end with a dot
    while (clean.endsWith('.')) {
      clean = clean.substring(0, clean.length - 1);
    }

    return '$clean.$ext';
  }

  static bool isSafeExtension(String ext) {
    final clean = ext.toLowerCase().replaceAll('.', '').trim();
    if (_disallowedExtensions.contains(clean)) return false;
    return _allowedExtensions.contains(clean);
  }

  static String? _inferExtensionFromMime(String? mime) {
    if (mime == null) return null;
    final lower = mime.toLowerCase();
    if (lower.contains('image/jpeg')) return 'jpg';
    if (lower.contains('image/png')) return 'png';
    if (lower.contains('image/webp')) return 'webp';
    if (lower.contains('image/gif')) return 'gif';
    if (lower.contains('image/svg')) return 'svg';
    if (lower.contains('video/mp4')) return 'mp4';
    if (lower.contains('video/webm')) return 'webm';
    if (lower.contains('video/quicktime')) return 'mov';
    if (lower.contains('audio/mpeg') || lower.contains('audio/mp3')) return 'mp3';
    if (lower.contains('audio/ogg')) return 'ogg';
    if (lower.contains('audio/flac')) return 'flac';
    if (lower.contains('audio/wav')) return 'wav';
    if (lower.contains('application/pdf')) return 'pdf';
    return null;
  }
}
