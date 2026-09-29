import 'dart:convert';
import 'package:permission_media_downloader/models/download_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadHistoryService {
  static final DownloadHistoryService instance = DownloadHistoryService._internal();

  factory DownloadHistoryService() => instance;

  DownloadHistoryService._internal();

  static const String _storageKey = 'local_download_history_v1';

  Future<List<DownloadItem>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];
      final list = <DownloadItem>[];
      for (final raw in rawList) {
        try {
          final map = json.decode(raw) as Map<String, dynamic>;
          list.add(DownloadItem.fromJson(map));
        } catch (_) {}
      }
      // Sort newest first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistoryItem(DownloadItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await loadHistory();
      final idx = existing.indexWhere((e) => e.id == item.id);
      if (idx >= 0) {
        existing[idx] = item;
      } else {
        existing.insert(0, item);
      }

      final stringList = existing.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList(_storageKey, stringList);
    } catch (_) {}
  }

  Future<void> removeHistoryItem(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await loadHistory();
      existing.removeWhere((e) => e.id == id);
      final stringList = existing.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList(_storageKey, stringList);
    } catch (_) {}
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }
}
