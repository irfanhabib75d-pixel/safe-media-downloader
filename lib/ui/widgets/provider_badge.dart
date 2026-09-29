import 'package:flutter/material.dart';
import 'package:permission_media_downloader/models/media_source.dart';
import 'package:permission_media_downloader/ui/theme/app_theme.dart';

class ProviderBadge extends StatelessWidget {
  final String providerName;
  final SourceSupportStatus status;

  const ProviderBadge({
    super.key,
    required this.providerName,
    this.status = SourceSupportStatus.supported,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case SourceSupportStatus.supported:
        bg = AppColors.accentEmerald.withOpacity(0.12);
        fg = AppColors.accentEmerald;
        icon = Icons.verified;
        break;
      case SourceSupportStatus.requiresAuth:
        bg = AppColors.accentAmber.withOpacity(0.12);
        fg = AppColors.accentAmber;
        icon = Icons.vpn_key;
        break;
      case SourceSupportStatus.unsupported:
        bg = AppColors.accentCoral.withOpacity(0.12);
        fg = AppColors.accentCoral;
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            providerName,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
