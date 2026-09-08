import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';

class DemoUserSelectorDialog extends ConsumerWidget {
  const DemoUserSelectorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const DemoUserSelectorDialog(),
    );
  }

  void _selectProfile(BuildContext context, WidgetRef ref, UserRole role) async {
    Navigator.of(context).pop();
    await ref.read(authStateProvider.notifier).switchDemoProfile(role);
    if (!context.mounted) return;

    switch (role) {
      case UserRole.citizen:
        context.goNamed(RouteNames.citizenHome);
        break;
      case UserRole.fieldOfficer:
        context.goNamed(RouteNames.officerDashboard);
        break;
      case UserRole.authorityAdmin:
        context.goNamed(RouteNames.adminCommandCenter);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Judge / Evaluation Demo Switcher', style: AppTypography.heading3),
                    Text(
                      'Instant 1-tap RBAC profile switching for evaluation',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            _buildOption(
              context: context,
              title: 'Citizen Portal (Ayush Sharma)',
              subtitle: 'Tawang, Arunachal • Live Risk Dial, Weather, 1-Tap Reports',
              badge: 'CITIZEN',
              badgeColor: AppColors.riskLow,
              icon: Icons.person_pin_circle_outlined,
              onTap: () => _selectProfile(context, ref, UserRole.citizen),
            ),
            const SizedBox(height: 10),

            _buildOption(
              context: context,
              title: 'Field Officer Console (Inspector T. Dorjee)',
              subtitle: 'West Kameng Sector • Offline Sync, Verification Checklist',
              badge: 'FIELD CREW',
              badgeColor: AppColors.riskModerate,
              icon: Icons.assignment_turned_in_outlined,
              onTap: () => _selectProfile(context, ref, UserRole.fieldOfficer),
            ),
            const SizedBox(height: 10),

            _buildOption(
              context: context,
              title: 'Authority Command Desk (Dr. P.K. Hazarika)',
              subtitle: 'State Disaster Authority • 8-State NER Matrix, SOS Prioritizer',
              badge: 'AUTHORITY / SDMA',
              badgeColor: AppColors.riskCritical,
              icon: Icons.admin_panel_settings_outlined,
              onTap: () => _selectProfile(context, ref, UserRole.authorityAdmin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: badgeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.heading3.copyWith(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: AppTypography.caption.copyWith(
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
