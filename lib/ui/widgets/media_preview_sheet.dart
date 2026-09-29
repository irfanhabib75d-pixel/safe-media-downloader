import 'package:flutter/material.dart';
import 'package:permission_media_downloader/l10n/app_localizations.dart';
import 'package:permission_media_downloader/models/download_item.dart';
import 'package:permission_media_downloader/models/media_option.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';
import 'package:permission_media_downloader/ui/widgets/rights_confirmation_dialog.dart';
import 'package:uuid/uuid.dart';

class MediaPreviewSheet extends StatefulWidget {
  final MediaInspectionResult inspection;
  final Function(DownloadItem item) onStartDownload;

  const MediaPreviewSheet({
    super.key,
    required this.inspection,
    required this.onStartDownload,
  });

  @override
  State<MediaPreviewSheet> createState() => _MediaPreviewSheetState();
}

class _MediaPreviewSheetState extends State<MediaPreviewSheet> {
  late MediaOption _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.inspection.options.isNotEmpty
        ? widget.inspection.options.first
        : const MediaOption(
            id: 'default',
            label: 'Default Quality',
            downloadUrl: '',
            mimeType: 'application/octet-stream',
            fileExtension: 'dat',
          );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentEmerald.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.accentEmerald, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.get('media_ready_title'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.inspection.providerName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accentEmerald,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  label: l10n.get('media_title'),
                  value: widget.inspection.title.isNotEmpty
                      ? widget.inspection.title
                      : 'Media File',
                  isDark: isDark,
                  bold: true,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  label: l10n.get('media_author'),
                  value: widget.inspection.author,
                  isDark: isDark,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  label: l10n.get('media_license'),
                  value: widget.inspection.licenseName,
                  isDark: isDark,
                  valueColor: AppColors.accentEmerald,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  label: 'Save Destination',
                  value: 'Device Downloads / MediaStore',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quality / Option selector
          if (widget.inspection.options.length > 1) ...[
            Text(
              l10n.get('select_option'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MediaOption>(
                  isExpanded: true,
                  value: _selectedOption,
                  dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  items: widget.inspection.options.map((opt) {
                    return DropdownMenuItem<MediaOption>(
                      value: opt,
                      child: Text(
                        '${opt.label} • ${opt.formattedSize}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedOption = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Download CTA
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download_rounded, size: 20),
              label: Text(l10n.get('start_download_btn')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                // Trigger rights confirmation
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => RightsConfirmationDialog(
                    mediaTitle: widget.inspection.title,
                    author: widget.inspection.author,
                    licenseName: widget.inspection.licenseName,
                  ),
                );

                if (confirmed == true && mounted) {
                  Navigator.of(context).pop();

                  final item = DownloadItem(
                    id: const Uuid().v4(),
                    originalUrl: widget.inspection.sourceWebUrl ?? _selectedOption.downloadUrl,
                    downloadUrl: _selectedOption.downloadUrl,
                    title: widget.inspection.title.isNotEmpty
                        ? widget.inspection.title
                        : 'media_${DateTime.now().millisecondsSinceEpoch}',
                    sourceProvider: widget.inspection.providerName,
                    author: widget.inspection.author,
                    licenseName: widget.inspection.licenseName,
                    licenseUrl: widget.inspection.licenseUrl,
                    mimeType: _selectedOption.mimeType,
                    fileExtension: _selectedOption.fileExtension,
                    totalBytes: _selectedOption.estimatedSizeBytes ?? 0,
                    createdAt: DateTime.now(),
                  );

                  widget.onStartDownload(item);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required bool isDark,
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
