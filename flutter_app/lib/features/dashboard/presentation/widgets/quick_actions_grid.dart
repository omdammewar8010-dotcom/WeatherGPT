import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onOpenMap;
  final VoidCallback onReportIncident;
  final VoidCallback onWeather;
  final VoidCallback onEmergency;
  final VoidCallback? onRoads;
  final VoidCallback? onAlerts;

  const QuickActionsGrid({
    super.key,
    required this.onOpenMap,
    required this.onReportIncident,
    required this.onWeather,
    required this.onEmergency,
    this.onRoads,
    this.onAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMERGENCY & OPERATIONS',
          style: AppTypography.caption.copyWith(
            letterSpacing: 0.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [
            _buildActionTile(
              title: 'GIS Risk Map',
              subtitle: 'Interactive weather radar map',
              icon: Icons.map_outlined,
              color: AppColors.accent,
              onTap: onOpenMap,
            ),
            _buildActionTile(
              title: 'Report Incident',
              subtitle: 'Crowdsourced weather spotter',
              icon: Icons.add_a_photo_outlined,
              color: AppColors.riskCritical,
              onTap: onReportIncident,
            ),
            _buildActionTile(
              title: 'Rainfall Radar',
              subtitle: 'Doppler dBZ & Nowcasting',
              icon: Icons.cloudy_snowing,
              color: AppColors.accentLight,
              onTap: onWeather,
            ),
            _buildActionTile(
              title: 'Emergency SOS',
              subtitle: 'Helpline & severe alert',
              icon: Icons.phone_in_talk_outlined,
              color: AppColors.riskHigh,
              onTap: onEmergency,
            ),
            if (onRoads != null)
              _buildActionTile(
                title: 'Sector Advisories',
                subtitle: 'Agromet, Aviation, Marine, City',
                icon: Icons.business_center_rounded,
                color: AppColors.riskModerate,
                onTap: onRoads!,
              ),
            if (onAlerts != null)
              _buildActionTile(
                title: 'Alert Center',
                subtitle: 'IMD color warnings & sirens',
                icon: Icons.notifications_active_outlined,
                color: AppColors.riskCritical,
                onTap: onAlerts!,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: AppTypography.heading3.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
