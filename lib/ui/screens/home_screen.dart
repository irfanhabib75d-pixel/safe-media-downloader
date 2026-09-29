import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_media_downloader/l10n/app_localizations.dart';
import 'package:permission_media_downloader/models/download_item.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/services/providers/source_registry.dart';
import 'package:permission_media_downloader/services/security/url_validator.dart';
import 'package:permission_media_downloader/state/auth_notifier.dart';
import 'package:permission_media_downloader/state/download_queue_notifier.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';
import 'package:permission_media_downloader/ui/widgets/media_preview_sheet.dart';
import 'package:permission_media_downloader/ui/widgets/provider_badge.dart';
import 'package:permission_media_downloader/ui/widgets/unsupported_source_dialog.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToQueue;
  final VoidCallback onNavigateToDownloads;

  const HomeScreen({
    super.key,
    required this.onNavigateToQueue,
    required this.onNavigateToDownloads,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isInspecting = false;
  String? _inlineError;

  @override
  void dispose() {
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      setState(() {
        _urlController.text = data.text!.trim();
        _inlineError = null;
      });
      _inspectUrl();
    }
  }

  Future<void> _inspectUrl() async {
    final rawUrl = _urlController.text.trim();
    final l10n = AppLocalizations.of(context);

    if (rawUrl.isEmpty) {
      setState(() => _inlineError = l10n.get('err_empty_url'));
      return;
    }

    final validation = UrlValidator.validateInputUrl(rawUrl);
    if (!validation.isValid) {
      setState(() => _inlineError = validation.errorMessage ?? l10n.get('err_invalid_url'));
      return;
    }

    setState(() {
      _isInspecting = true;
      _inlineError = null;
    });

    try {
      final authNotifier = context.read<AuthNotifier>();
      final uri = validation.parsedUri!;
      final adapter = SourceRegistry.instance.findAdapterForUrl(uri);

      String? customApiKey;
      if (adapter != null) {
        customApiKey = await authNotifier.getCustomApiKey(adapter.sourceInfo.id);
      }

      final result = await SourceRegistry.instance.inspectUrl(
        rawUrl,
        apiKey: customApiKey,
      );

      if (!mounted) return;

      if (!result.isSupported) {
        await showDialog(
          context: context,
          builder: (_) => UnsupportedSourceDialog(
            providerName: result.providerName,
            reason: result.unsupportedReason ?? l10n.get('err_unsupported_desc'),
            officialAppUrl: result.suggestedOfficialAppUrl,
            docRefUrl: result.docReviewRef,
          ),
        );
      } else {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => MediaPreviewSheet(
            inspection: result,
            onStartDownload: (DownloadItem item) {
              context.read<DownloadQueueNotifier>().enqueueDownload(item);
              _urlController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added "${item.title}" to download queue.'),
                  action: SnackBarAction(
                    label: 'View Queue',
                    textColor: AppColors.primaryBlueLight,
                    onPressed: widget.onNavigateToQueue,
                  ),
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _inlineError = 'Inspection failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isInspecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sources = SourceRegistry.instance.allSupportedAdapters;
    final completedItems = context.watch<DownloadQueueNotifier>().completedItems;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.download_done_rounded,
                  color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 10),
            Text(l10n.get('app_title')),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '100% Policy Compliant',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.get('home_header_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.get('home_header_subtitle'),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // URL Input Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _urlController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: l10n.get('url_input_placeholder'),
                        prefixIcon: const Icon(Icons.link, size: 20),
                        suffixIcon: _urlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _urlController.clear();
                                  setState(() => _inlineError = null);
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _inspectUrl(),
                      onChanged: (_) {
                        if (_inlineError != null) {
                          setState(() => _inlineError = null);
                        }
                      },
                    ),

                    if (_inlineError != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 14, color: AppColors.accentCoral),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _inlineError!,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.accentCoral),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Action buttons
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.content_paste, size: 16),
                          label: Text(l10n.get('paste_button')),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _pasteFromClipboard,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isInspecting ? null : _inspectUrl,
                            child: _isInspecting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(l10n.get('inspect_button')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Supported Sources Guide
            Text(
              l10n.get('supported_sources_title'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.get('supported_sources_desc'),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Source list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sources.length,
              itemBuilder: (context, idx) {
                final src = sources[idx].sourceInfo;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      child: const Icon(Icons.check,
                          color: AppColors.primaryBlue, size: 18),
                    ),
                    title: Row(
                      children: [
                        Text(
                          src.displayName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        ProviderBadge(
                          providerName: 'Official API',
                          status: SourceSupportStatus.supported,
                        ),
                      ],
                    ),
                    subtitle: Text(
                      src.policySummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),

            if (completedItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.get('recent_downloads_title'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToDownloads,
                    child: Text(l10n.get('view_all')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Recent item card
              Card(
                child: ListTile(
                  leading: const Icon(Icons.file_download_done,
                      color: AppColors.accentEmerald),
                  title: Text(
                    completedItems.first.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${completedItems.first.sourceProvider} • ${completedItems.first.formattedTotalSize}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: widget.onNavigateToDownloads,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
