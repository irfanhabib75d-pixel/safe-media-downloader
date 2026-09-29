import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() => instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(initSettings);
      _isInitialized = true;
    } catch (_) {
      // Graceful fallback if running in test environment
    }
  }

  Future<void> showDownloadProgress({
    required int id,
    required String title,
    required int progressPercent,
    required String statusText,
  }) async {
    if (!_isInitialized) return;

    final androidDetails = AndroidNotificationDetails(
      'active_downloads_channel',
      'Active Media Downloads',
      channelDescription: 'Shows live progress for active user-started downloads',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progressPercent,
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        id,
        title,
        statusText,
        details,
      );
    } catch (_) {}
  }

  Future<void> showDownloadCompleted({
    required int id,
    required String title,
    required String filePath,
  }) async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'completed_downloads_channel',
      'Completed Downloads',
      channelDescription: 'Notifications when media has safely finished saving',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        id,
        'Download Complete: $title',
        'Media saved safely to your device.',
        details,
        payload: filePath,
      );
    } catch (_) {}
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    try {
      await _notificationsPlugin.cancel(id);
    } catch (_) {}
  }
}
