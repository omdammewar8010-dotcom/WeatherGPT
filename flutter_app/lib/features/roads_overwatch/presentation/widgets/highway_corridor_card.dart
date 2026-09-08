import 'package:flutter/material.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/features/roads_overwatch/domain/entities/road_corridor_entity.dart';

class HighwayCorridorCard extends StatelessWidget {
  final RoadCorridorEntity corridor;

  const HighwayCorridorCard({super.key, required this.corridor});

  Color get _statusColor {
    switch (corridor.status) {
      case 'TOTAL_BLOCKAGE':
        return AppColors.riskCritical;
      case 'PARTIALLY_BLOCKED':
        return AppColors.riskHigh;
      case 'VULNERABLE':
        return AppColors.riskModerate;
      case 'CLEAR':
      default:
        return AppColors.riskLow;
    }
  }

  IconData get _statusIcon {
    switch (corridor.status) {
      case 'TOTAL_BLOCKAGE':
        return Icons.block_rounded;
      case 'PARTIALLY_BLOCKED':
        return Icons.warning_rounded;
      case 'VULNERABLE':
        return Icons.speed_rounded;
      case 'CLEAR':
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Highway name & status chip
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(corridor.highwayName, style: AppTypography.heading3.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      '${corridor.section} • ${corridor.district} (${corridor.state})',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      corridor.status.replaceAll('_', ' '),
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Blockage Cause
          if (corridor.blockageCause != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.landslide_rounded, size: 16, color: AppColors.riskHigh),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      corridor.blockageCause!,
                      style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Clearance Progress & ETA
          if (corridor.status != 'CLEAR') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('BRO Clearance Progress:', style: AppTypography.caption),
                Text(
                  '${corridor.clearingProgressPct}% Complete • ETA: ${corridor.estimatedReopeningHours ?? 0}h',
                  style: AppTypography.caption.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (corridor.clearingProgressPct / 100.0).clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceLight,
                color: statusColor,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Alternate Detour Box
          if (corridor.alternateDetour != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alt_route_rounded, size: 16, color: AppColors.accentLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RECOMMENDED ALTERNATE DETOUR', style: AppTypography.caption.copyWith(color: AppColors.accentLight, fontSize: 9, fontWeight: FontWeight.bold)),
                        Text(corridor.alternateDetour!, style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Footer: Last updated
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Project Vartak / Swastik Unit', style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textMuted)),
              Text('Updated ${corridor.lastReported}', style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
