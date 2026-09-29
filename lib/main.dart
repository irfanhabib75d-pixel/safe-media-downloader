import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_media_downloader/l10n/app_localizations.dart';
import 'package:permission_media_downloader/services/notification/notification_service.dart';
import 'package:permission_media_downloader/state/auth_notifier.dart';
import 'package:permission_media_downloader/state/download_queue_notifier.dart';
import 'package:permission_media_downloader/state/locale_notifier.dart';
import 'package:permission_media_downloader/state/theme_notifier.dart';
import 'package:permission_media_downloader/ui/screens/main_navigation_screen.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService.instance.initialize();

  // Initialize providers
  final downloadQueueNotifier = DownloadQueueNotifier();
  final authNotifier = AuthNotifier();
  final themeNotifier = ThemeNotifier();
  final localeNotifier = LocaleNotifier();

  // Load persistent history and stored keys
  await downloadQueueNotifier.loadSavedHistory();
  await authNotifier.loadCustomKeys();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: downloadQueueNotifier),
        ChangeNotifierProvider.value(value: authNotifier),
        ChangeNotifierProvider.value(value: themeNotifier),
        ChangeNotifierProvider.value(value: localeNotifier),
      ],
      child: const SafeMediaDownloaderApp(),
    ),
  );
}

class SafeMediaDownloaderApp extends StatelessWidget {
  const SafeMediaDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final localeNotifier = context.watch<LocaleNotifier>();

    return MaterialApp(
      title: 'Safe Media Downloader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      locale: localeNotifier.currentLocale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ur', 'Latn'),
      ],
      home: const MainNavigationScreen(),
    );
  }
}
