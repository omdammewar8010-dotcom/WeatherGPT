import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../app.dart';

class AuthSelectionScreen extends ConsumerWidget {
  const AuthSelectionScreen({super.key});

  void _loginAsRole(BuildContext context, WidgetRef ref, String role) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setUserRole(role);
    await storage.setDemoMode(true);

    if (!context.mounted) return;

    if (role == AppConstants.roleCitizen) {
      context.goNamed(RouteNames.citizenHome);
    } else if (role == AppConstants.roleFieldOfficer) {
      context.goNamed(RouteNames.officerDashboard);
    } else {
      context.goNamed(RouteNames.adminCommandCenter);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Brand Heading
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Icon(
                      Icons.landscape_rounded,
                      color: AppColors.accentLight,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NER-LandslideGuard', style: AppTypography.heading2),
                      Text(
                        'Disaster Management Portal',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Welcome Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to NER Early Warning',
                      style: AppTypography.heading3,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select your operational portal or use the instant evaluation demo profile.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Text(
                'EXPLORE AS DEMO USER',
                style: AppTypography.caption.copyWith(color: AppColors.accentLight),
              ),
              const SizedBox(height: 12),

              // Role Card 1: Citizen
              _buildRoleCard(
                context: context,
                title: 'Citizen Portal',
                subtitle: 'Hyperlocal risk score, weather, early warnings & 1-tap incident reporting',
                icon: Icons.person_pin_circle_outlined,
                badgeColor: AppColors.riskLow,
                badgeText: 'PUBLIC ACCESS',
                onTap: () => _loginAsRole(context, ref, AppConstants.roleCitizen),
              ),

              const SizedBox(height: 12),

              // Role Card 2: Field Officer
              _buildRoleCard(
                context: context,
                title: 'Field Officer Console',
                subtitle: 'Assigned incident verification, on-site telemetry & offline GPS reporting',
                icon: Icons.assignment_turned_in_outlined,
                badgeColor: AppColors.riskModerate,
                badgeText: 'FIELD CREW',
                onTap: () => _loginAsRole(context, ref, AppConstants.roleFieldOfficer),
              ),

              const SizedBox(height: 12),

              // Role Card 3: Authority Admin
              _buildRoleCard(
                context: context,
                title: 'Authority Command Desk',
                subtitle: '8-State NER overwatch, multi-criteria emergency ranking & broadcast alerts',
                icon: Icons.admin_panel_settings_outlined,
                badgeColor: AppColors.riskCritical,
                badgeText: 'AUTHORITY / SDMA',
                onTap: () => _loginAsRole(context, ref, AppConstants.roleAuthorityAdmin),
              ),

              const SizedBox(height: 32),

              // Standard Sign In Form divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR CREDENTIAL LOGIN', style: AppTypography.caption),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // Input fields
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email or Mobile Number',
                  prefixIcon: Icon(Icons.account_circle_outlined, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loginAsRole(context, ref, AppConstants.roleCitizen),
                child: const Text('Sign In Securely'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color badgeColor,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: badgeColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTypography.heading3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          badgeText,
                          style: AppTypography.caption.copyWith(
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
