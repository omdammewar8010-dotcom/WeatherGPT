import 'package:flutter/material.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/features/emergency/domain/entities/emergency_sos_entity.dart';

class McdaTriageIncidentTile extends StatelessWidget {
  final EmergencySosEntity incident;
  final ValueChanged<String>? onStatusChanged;

  const McdaTriageIncidentTile({
    super.key,
    required this.incident,
    this.onStatusChanged,
  });

  Color _getPriorityColor() {
    if (incident.priorityLevel.startsWith('P1')) return AppColors.riskCritical;
    if (incident.priorityLevel.startsWith('P2')) return AppColors.riskHigh;
    return AppColors.riskModerate;
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();
    final factors = EmergencyMcdaCalculator.getUrgencyFactors(
      trappedCount: incident.trappedCount,
      medicalEmergency: incident.medicalEmergency,
      roadCutOff: incident.roadCutOff,
      vulnerableDependents: incident.vulnerableDependents,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: priorityColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Priority Chip & MCDA Score
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: priorityColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      incident.priorityLevel.startsWith('P1')
                          ? Icons.flight_takeoff_rounded
                          : Icons.emergency_rounded,
                      color: priorityColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      incident.priorityLevel.replaceAll('_', ' '),
                      style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'MCDA: ${incident.triageScore.toInt()}/100',
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // District & ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${incident.district}, ${incident.state}',
                style: AppTypography.heading3.copyWith(fontSize: 15),
              ),
              Text(incident.id, style: AppTypography.caption.copyWith(color: AppColors.accentLight)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reporter: ${incident.reporterName} (${incident.reporterPhone})',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          // Urgency Factor Pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: factors.map((factor) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '• $factor',
                  style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontSize: 10),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Dispatched Unit
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.accentLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Assigned: ${incident.dispatchedUnit}',
                    style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Lifecycle & Status Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: incident.status == 'RESOLVED'
                          ? AppColors.riskLow
                          : (incident.status == 'RESCUE_IN_PROGRESS'
                              ? AppColors.riskHigh
                              : AppColors.riskCritical),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    incident.status.replaceAll('_', ' '),
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (onStatusChanged != null)
                PopupMenuButton<String>(
                  color: AppColors.surfaceLight,
                  onSelected: onStatusChanged,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'DISPATCHED', child: Text('DISPATCHED')),
                    PopupMenuItem(value: 'RESCUE_IN_PROGRESS', child: Text('RESCUE IN PROGRESS')),
                    PopupMenuItem(value: 'RESOLVED', child: Text('RESOLVED / SAFE')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Update Status', style: AppTypography.caption),
                        const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
