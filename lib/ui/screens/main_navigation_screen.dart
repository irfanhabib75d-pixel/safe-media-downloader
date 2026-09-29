import 'package:flutter/material.dart';
import 'package:permission_media_downloader/l10n/app_localizations.dart';
import 'package:permission_media_downloader/state/download_queue_notifier.dart';
import 'package:permission_media_downloader/ui/screens/downloads_screen.dart';
import 'package:permission_media_downloader/ui/screens/home_screen.dart';
import 'package:permission_media_downloader/ui/screens/queue_screen.dart';
import 'package:permission_media_downloader/ui/screens/settings_screen.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final queueItems = context.watch<DownloadQueueNotifier>().activeAndQueuedItems;
    final activeCount = queueItems.length;

    final screens = [
      HomeScreen(
        onNavigateToQueue: () => _navigateToTab(1),
        onNavigateToDownloads: () => _navigateToTab(2),
      ),
      QueueScreen(
        onNavigateToHome: () => _navigateToTab(0),
      ),
      DownloadsScreen(
        onNavigateToHome: () => _navigateToTab(0),
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToTab,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.get('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: activeCount > 0,
              label: Text('$activeCount'),
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.queue_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: activeCount > 0,
              label: Text('$activeCount'),
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.queue),
            ),
            label: l10n.get('nav_queue'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.download_done_outlined),
            activeIcon: const Icon(Icons.download_done),
            label: l10n.get('nav_downloads'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l10n.get('nav_settings'),
          ),
        ],
      ),
    );
  }
}
