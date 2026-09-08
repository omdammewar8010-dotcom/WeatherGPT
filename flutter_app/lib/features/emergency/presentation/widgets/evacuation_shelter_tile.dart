import 'package:flutter/material.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/features/emergency/domain/entities/emergency_sos_entity.dart';

class EvacuationShelterTile extends StatelessWidget {
  final EvacuationShelterEntity shelter;

  const EvacuationShelterTile({super.key, required this.shelter});

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
          // Header: Name & Distance
          Row(
            children: [
              const Icon(Icons.night_shelter_rounded, color: AppColors.riskLow, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shelter.name,
                  style: AppTypography.heading3.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${shelter.distanceKm} km away',
                  style: const TextStyle(color: AppColors.accentLight, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // District
          Text(
            '${shelter.district}, ${shelter.state}',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),

          // Occupancy Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bed Occupancy:', style: AppTypography.caption),
              Text(
                '${shelter.capacityOccupied} / ${shelter.capacityTotal} Beds (${(shelter.occupancyRate * 100).toInt()}%)',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: shelter.occupancyRate > 0.8 ? AppColors.riskHigh : AppColors.riskLow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: shelter.occupancyRate,
              backgroundColor: AppColors.surfaceLight,
              color: shelter.occupancyRate > 0.8 ? AppColors.riskHigh : AppColors.riskLow,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Feature Badges
          Row(
            children: [
              if (shelter.helipadAvailable)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.flight_land_rounded, color: Colors.blue, size: 12),
                      SizedBox(width: 4),
                      Text('IAF Helipad', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              if (shelter.medicalFacility)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.riskLow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.riskLow.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.medical_services_rounded, color: AppColors.riskLow, size: 12),
                      SizedBox(width: 4),
                      Text('24x7 Medical Bay', style: TextStyle(color: AppColors.riskLow, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Officer & Contact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shelter.contactOfficer, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                    Text(shelter.contactPhone, style: AppTypography.caption.copyWith(color: AppColors.accentLight)),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone, size: 14),
                  label: const Text('CALL SHELTER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
