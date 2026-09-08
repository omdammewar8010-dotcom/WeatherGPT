import 'package:flutter/material.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/features/roads_overwatch/domain/entities/road_corridor_entity.dart';

class HistoricalEventCard extends StatelessWidget {
  final HistoricalLandslideEventEntity event;

  const HistoricalEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Location and Year
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.accentLight.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${event.month} ${event.year}',
                  style: const TextStyle(color: AppColors.accentLight, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.locationName,
                  style: AppTypography.heading3.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${event.district}, ${event.state} • Severed: ${event.highwaySevered}',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // 3-Metric Row
          Row(
            children: [
              Expanded(
                child: _buildBadge(
                  icon: Icons.layers_rounded,
                  label: 'Debris Volume',
                  value: '${event.debrisVolumeM3.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} m³',
                  color: AppColors.riskHigh,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBadge(
                  icon: Icons.person_remove_rounded,
                  label: 'Casualties',
                  value: '${event.fatalitiesCount}',
                  color: event.fatalitiesCount > 0 ? AppColors.riskCritical : AppColors.riskLow,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBadge(
                  icon: Icons.timer_rounded,
                  label: 'Restoration',
                  value: '${event.restorationDays} Days',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Trigger mechanism
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 14, color: AppColors.accentLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Trigger: ${event.triggerMechanism}',
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Geotechnical Summary
          Text(
            event.geotechnicalSummary,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: color, fontSize: 11),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(fontSize: 8, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
