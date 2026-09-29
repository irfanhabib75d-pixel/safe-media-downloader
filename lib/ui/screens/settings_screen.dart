import 'package:flutter/material.dart';
import 'package:permission_media_downloader/l10n/app_localizations.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/services/download/file_storage_service.dart';
import 'package:permission_media_downloader/services/providers/source_registry.dart';
import 'package:permission_media_downloader/state/locale_notifier.dart';
import 'package:permission_media_downloader/state/theme_notifier.dart';
import 'package:permission_media_downloader/ui/screens/provider_auth_screen.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';
import 'package:permission_media_downloader/ui/widgets/provider_badge.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localeNotifier = context.watch<LocaleNotifier>();
    final themeNotifier = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('settings_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: General
          _buildSectionHeader(l10n.get('section_general'), isDark),
          Card(
            child: Column(
              children: [
                // Language
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primaryBlue),
                  title: Text(l10n.get('language_label')),
                  subtitle: Text(localeNotifier.currentLanguage.displayName),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<AppLanguage>(
                      value: localeNotifier.currentLanguage,
                      dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      items: AppLanguage.values.map((lang) {
                        return DropdownMenuItem<AppLanguage>(
                          value: lang,
                          child: Text(lang.displayName),
                        );
                      }).toList(),
                      onChanged: (lang) {
                        if (lang != null) {
                          localeNotifier.setLanguage(lang);
                        }
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Theme
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: AppColors.accentEmerald),
                  title: Text(l10n.get('theme_label')),
                  subtitle: Text(_getThemeName(themeNotifier.themeMode, l10n)),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<ThemeMode>(
                      value: themeNotifier.themeMode,
                      dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(l10n.get('theme_system')),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(l10n.get('theme_light')),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(l10n.get('theme_dark')),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          themeNotifier.setThemeMode(mode);
                        }
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Provider Auth screen
                ListTile(
                  leading: const Icon(Icons.key_outlined, color: AppColors.accentViolet),
                  title: const Text('Provider Authorization & Keys'),
                  subtitle: const Text('Manage official developer credentials'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProviderAuthScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Storage & Security
          _buildSectionHeader(l10n.get('section_storage'), isDark),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.folder_outlined, color: AppColors.primaryBlue),
                  title: Text(l10n.get('save_location_label')),
                  subtitle: Text(l10n.get('save_location_desc')),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppColors.accentEmerald),
                  title: Text(l10n.get('secure_keystore_status')),
                  subtitle: Text(l10n.get('secure_keystore_active')),
                  trailing: const Icon(Icons.verified, color: AppColors.accentEmerald, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Compliance & Transparency
          _buildSectionHeader(l10n.get('section_compliance'), isDark),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.table_chart_outlined, color: AppColors.primaryBlue),
                  title: Text(l10n.get('supported_sources_matrix')),
                  subtitle: const Text('View permitted & blocked platform policies'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSourceMatrixModal(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined, color: AppColors.accentAmber),
                  title: Text(l10n.get('terms_of_service')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDocumentDialog(
                    context,
                    title: l10n.get('terms_of_service'),
                    content:
                        'Safe Media Downloader is built strictly for permission-first media retrieval. Users must possess appropriate rights or Creative Commons licenses for downloaded assets. Downloading media from unsupported sources is strictly prohibited.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.accentEmerald),
                  title: Text(l10n.get('privacy_policy')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDocumentDialog(
                    context,
                    title: l10n.get('privacy_policy'),
                    content:
                        'Privacy-First Architecture: Safe Media Downloader runs entirely on-device without remote tracking servers, analytics, or ads. Download history is stored exclusively in your local device sandbox.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.accentViolet),
                  title: Text(l10n.get('about_app')),
                  subtitle: Text(l10n.get('app_version')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Disclaimer Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              l10n.get('disclaimer_notice'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.get('theme_system');
      case ThemeMode.light:
        return l10n.get('theme_light');
      case ThemeMode.dark:
        return l10n.get('theme_dark');
    }
  }

  void _showSourceMatrixModal(BuildContext context) {
    final allSources = SourceRegistry.instance.getAllSources();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Official Source Support Matrix',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Verified against official Terms of Service and API documentation.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: allSources.length,
                      itemBuilder: (ctx, idx) {
                        final src = allSources[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      src.displayName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    ProviderBadge(
                                      providerName: src.supportStatus == SourceSupportStatus.supported
                                          ? 'Supported'
                                          : 'Unsupported',
                                      status: src.supportStatus,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  src.policySummary,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Permitted Method: ${src.permittedMethod}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Reviewed: ${src.reviewDate}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDocumentDialog(BuildContext context, {required String title, required String content}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.45),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
