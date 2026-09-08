import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync/background_sync_service.dart';
import '../services/sync/connectivity_service.dart';
import '../services/sync/sync_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SyncStatusPillWidget extends ConsumerWidget {
  const SyncStatusPillWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netAsync = ref.watch(networkStatusStreamProvider);
    final syncAsync = ref.watch(syncProgressStreamProvider);

    final netStatus = netAsync.value ?? NetworkStatus.online;
    final progress = syncAsync.value ?? const SyncProgress();

    if (netStatus == NetworkStatus.online && !progress.isSyncing && progress.total == 0) {
      return const SizedBox.shrink(); // Quiet state when fully synced
    }

    Color bgColor;
    Color borderColor;
    IconData icon;
    String message;

    if (!netStatus.isConnected) {
      bgColor = AppColors.riskModerate.withValues(alpha: 0.15);
      borderColor = AppColors.riskModerate;
      icon = Icons.cloud_off_rounded;
      message = 'Offline Queue: ${progress.total} item(s) pending sync';
    } else if (progress.isSyncing) {
      bgColor = AppColors.accent.withValues(alpha: 0.15);
      borderColor = AppColors.accentLight;
      icon = Icons.sync_rounded;
      message = progress.currentTaskName ?? 'Auto-syncing queued data...';
    } else {
      bgColor = AppColors.riskLow.withValues(alpha: 0.15);
      borderColor = AppColors.riskLow;
      icon = Icons.cloud_done_rounded;
      message = 'All changes synced with NDMA server';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: borderColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (netStatus.isConnected && !progress.isSyncing && progress.total > 0)
            GestureDetector(
              onTap: () {
                ref.read(backgroundSyncServiceProvider).syncAllPending(force: true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SYNC NOW',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
