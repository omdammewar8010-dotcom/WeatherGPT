import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final int pendingSyncCount;
  final VoidCallback? onForceSync;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.pendingSyncCount = 0,
    this.onForceSync,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && pendingSyncCount == 0) {
      return const SizedBox.shrink();
    }

    final isWarning = isOffline;
    final bgColor = isWarning ? AppColors.warning : AppColors.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(color: bgColor.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded,
            size: 16,
            color: bgColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOffline
                  ? 'OFFLINE MODE: Using cached terrain & sensor data.'
                  : '$pendingSyncCount pending reports synchronizing with cloud...',
              style: AppTypography.caption.copyWith(
                color: bgColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onForceSync != null && !isOffline) ...[
            TextButton(
              onPressed: onForceSync,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Sync Now',
                style: AppTypography.caption.copyWith(
                  color: bgColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
