import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SectorAdvisoriesCarousel extends StatelessWidget {
  final VoidCallback onOpenAdvisories;

  const SectorAdvisoriesCarousel({
    super.key,
    required this.onOpenAdvisories,
  });

  @override
  Widget build(BuildContext context) {
    final sectors = [
      {
        'title': 'Agromet (Farmers)',
        'subtitle': 'Sali Paddy & Plantation',
        'status': 'Open Field Drainage',
        'icon': Icons.agriculture_rounded,
        'color': AppColors.riskModerate,
        'badge': 'ORANGE ADVISORY',
      },
      {
        'title': 'Aviation & Drones',
        'subtitle': 'Ceiling 4,500ft • 18kt gusts',
        'status': 'Marginal VFR',
        'icon': Icons.flight_takeoff_rounded,
        'color': AppColors.riskHigh,
        'badge': 'CAUTION',
      },
      {
        'title': 'Marine & Coastal',
        'subtitle': 'Wave height 2.4m • 35kt squall',
        'status': 'Fishermen Alert',
        'icon': Icons.sailing_rounded,
        'color': AppColors.riskCritical,
        'badge': 'RED ALERT',
      },
      {
        'title': 'Smart City & Urban',
        'subtitle': 'Underpasses & Sump pumps',
        'status': 'Drain De-silting',
        'icon': Icons.location_city_rounded,
        'color': AppColors.accent,
        'badge': 'ACTIVE PREP',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.business_center_rounded, color: AppColors.accent, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'SECTOR DECISION ADVISORIES',
                  style: AppTypography.caption.copyWith(
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: onOpenAdvisories,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.accentLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.accentLight, size: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 138,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sectors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final sec = sectors[index];
              final color = sec['color'] as Color;

              return InkWell(
                onTap: onOpenAdvisories,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 210,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(sec['icon'] as IconData, color: color, size: 18),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: color.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                sec['badge'] as String,
                                style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sec['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sec['subtitle'] as String,
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sec['status'] as String,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
