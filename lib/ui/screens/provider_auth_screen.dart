import 'package:flutter/material.dart';
import 'package:permission_media_downloader/l10n/app_localizations.dart';
import 'package:permission_media_downloader/services/providers/source_registry.dart';
import 'package:permission_media_downloader/state/auth_notifier.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';
import 'package:permission_media_downloader/ui/widgets/provider_badge.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderAuthScreen extends StatelessWidget {
  const ProviderAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authNotifier = context.watch<AuthNotifier>();
    final supportedSources = SourceRegistry.instance.allSupportedAdapters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Authorization'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppColors.accentEmerald, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Secure Credentials Storage',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'All API keys & tokens are stored in Android Keystore / iOS Keychain. Credentials are never logged or transmitted to external servers.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Supported Provider Accounts & Keys',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          ...supportedSources.map((adapter) {
            final src = adapter.sourceInfo;
            final account = authNotifier.accounts[src.id];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          src.displayName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        ProviderBadge(
                          providerName: account?.isConnected == true ? 'Connected' : 'Ready',
                          status: src.supportStatus,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      src.policySummary,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.accentEmerald),
                        const SizedBox(width: 6),
                        Text(
                          account?.accountUsername ?? 'Active',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.description_outlined, size: 14),
                          label: const Text('API Docs'),
                          onPressed: () async {
                            final uri = Uri.parse(src.officialDocUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.key, size: 14),
                          label: Text(account?.isCustomApiKey == true ? 'Edit Key' : 'Add API Key'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () => _showApiKeyDialog(context, src.id, src.displayName),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, String providerId, String providerName) {
    final controller = TextEditingController();
    final authNotifier = context.read<AuthNotifier>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set $providerName API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your personal $providerName developer API key. It will be encrypted in secure device storage.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Paste API Key or Token here...',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authNotifier.setCustomApiKey(providerId, controller.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Securely'),
          ),
        ],
      ),
    );
  }
}
