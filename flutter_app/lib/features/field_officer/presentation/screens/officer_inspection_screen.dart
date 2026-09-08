import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/core/widgets/sync_status_pill_widget.dart';
import 'package:ner_landslideguard/features/authentication/presentation/providers/auth_provider.dart';
import 'package:ner_landslideguard/features/field_officer/domain/entities/geotechnical_inspection_entity.dart';
import 'package:ner_landslideguard/features/field_officer/presentation/providers/field_officer_provider.dart';
import 'package:ner_landslideguard/features/reports/domain/entities/incident_report_entity.dart';

class OfficerInspectionScreen extends ConsumerStatefulWidget {
  final IncidentReportEntity? incident;

  const OfficerInspectionScreen({super.key, this.incident});

  @override
  ConsumerState<OfficerInspectionScreen> createState() => _OfficerInspectionScreenState();
}

class _OfficerInspectionScreenState extends ConsumerState<OfficerInspectionScreen> {
  // Form State
  double _crackLength = 12.5;
  double _crackDepth = 35.0;
  double _slopeTilt = 3.8;
  bool _seepageVisible = true;
  bool _retainingWallDeformation = true;
  bool _vegetationDisturbance = false;
  double _soilMoisture = 82.0;
  String _geology = 'Fragile Schist / Colluvium';
  String _recommendedAction = 'Deploy Heavy Excavator & Clear Road';
  String _verificationStatus = 'VERIFIED';
  final TextEditingController _notesController = TextEditingController(
    text: 'Active slip plane observed along road bench. Tension crack propagating towards drainage culvert.',
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final officerState = ref.watch(fieldOfficerStateProvider);
    final targetIncident = widget.incident ?? officerState.activeInspectionIncident;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Geotechnical Inspection', style: AppTypography.heading2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SyncStatusPillWidget(),
            const SizedBox(height: 10),

            // 1. Incident Context Card
            if (targetIncident != null) _buildIncidentSnapshot(targetIncident),
            const SizedBox(height: 16),

            // 2. Section: Tension Crack Dimensions
            _buildSectionHeader('1. Fissure & Crack Dimensions', Icons.straighten_rounded),
            _buildSliderCard(
              label: 'Surface Crack Length (Meters)',
              value: _crackLength,
              min: 0.5,
              max: 100.0,
              unit: 'm',
              onChanged: (v) => setState(() => _crackLength = v),
            ),
            const SizedBox(height: 10),
            _buildSliderCard(
              label: 'Crack Depth / Aperture (Centimeters)',
              value: _crackDepth,
              min: 1.0,
              max: 200.0,
              unit: 'cm',
              onChanged: (v) => setState(() => _crackDepth = v),
            ),
            const SizedBox(height: 10),
            _buildSliderCard(
              label: 'Measured Slope Tilt Displacement',
              value: _slopeTilt,
              min: 0.0,
              max: 20.0,
              unit: '°',
              onChanged: (v) => setState(() => _slopeTilt = v),
            ),
            const SizedBox(height: 16),

            // 3. Section: Hydro-Geological Observations
            _buildSectionHeader('2. Hydrogeological Observations', Icons.water_drop_rounded),
            _buildSwitchTile(
              title: 'Visible Subsurface Water Seepage',
              subtitle: 'Active water bleeding from slope face or road cut',
              value: _seepageVisible,
              onChanged: (v) => setState(() => _seepageVisible = v),
            ),
            _buildSwitchTile(
              title: 'Retaining Wall / Gabion Bulging',
              subtitle: 'Structural masonry shear cracks or toe displacement',
              value: _retainingWallDeformation,
              onChanged: (v) => setState(() => _retainingWallDeformation = v),
            ),
            _buildSwitchTile(
              title: 'Vegetation / Tree Tilt (Jackstrawed Trees)',
              subtitle: 'Downslope leaning indicating active soil creep',
              value: _vegetationDisturbance,
              onChanged: (v) => setState(() => _vegetationDisturbance = v),
            ),
            const SizedBox(height: 10),
            _buildSliderCard(
              label: 'Soil Moisture Field Probe Reading',
              value: _soilMoisture,
              min: 10.0,
              max: 100.0,
              unit: '%',
              onChanged: (v) => setState(() => _soilMoisture = v),
            ),
            const SizedBox(height: 16),

            // 4. Section: Geology & Mitigation Action
            _buildSectionHeader('3. Geology & Recommended Action', Icons.construction_rounded),
            _buildDropdown(
              label: 'Observed Lithology / Formation',
              value: _geology,
              items: const [
                'Fragile Schist / Colluvium',
                'Siltstone / Weathered Shale',
                'Granitic Gneiss Complex',
                'Loose Hillside Overburden',
              ],
              onChanged: (v) => setState(() => _geology = v!),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'Immediate Mitigation Order',
              value: _recommendedAction,
              items: const [
                'Deploy Heavy Excavator & Clear Road',
                'Issue Immediate Evacuation Order',
                'Install Wire Netting & Rock Bolting',
                'Enforce Night Highway Transit Curfew',
                'Continuous Hourly Telemetry Monitoring',
              ],
              onChanged: (v) => setState(() => _recommendedAction = v!),
            ),
            const SizedBox(height: 16),

            // 5. Section: Verification Status & Sign-off Notes
            _buildSectionHeader('4. Verification Decision & Sign-off', Icons.verified_user_rounded),
            _buildDropdown(
              label: 'Verification Status',
              value: _verificationStatus,
              items: const [
                'VERIFIED',
                'ESCALATED_CRITICAL',
                'FALSE_ALARM',
                'RESOLVED',
              ],
              onChanged: (v) => setState(() => _verificationStatus = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Inspector Notes & Technical Observations',
                labelStyle: AppTypography.caption,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: officerState.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(
                  officerState.isSubmitting ? 'DISPATCHING INSPECTION...' : 'SUBMIT INSPECTION & SIGN-OFF',
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: officerState.isSubmitting
                    ? null
                    : () async {
                        final inspection = GeotechnicalInspectionEntity(
                          inspectionId: 'INSP-2026-${DateTime.now().millisecondsSinceEpoch % 10000}',
                          reportId: targetIncident?.id ?? 'LR-2026-000123',
                          inspectorId: currentUser?.id ?? 'off_pemba_01',
                          inspectorName: currentUser?.fullName ?? 'Inspector Pemba Dorjee',
                          inspectorBadge: currentUser?.badgeNumber ?? 'IND-AR-0442',
                          crackLengthMeters: _crackLength,
                          crackDepthCm: _crackDepth,
                          slopeTiltMeasuredDeg: _slopeTilt,
                          seepageVisible: _seepageVisible,
                          retainingWallDeformation: _retainingWallDeformation,
                          vegetationDisturbance: _vegetationDisturbance,
                          soilMoistureDirectReading: _soilMoisture,
                          geologicalFormationObserved: _geology,
                          recommendedAction: _recommendedAction,
                          officerNotes: _notesController.text.trim(),
                          verificationStatus: _verificationStatus,
                          inspectedAt: DateTime.now(),
                        );

                        final success = await ref
                            .read(fieldOfficerStateProvider.notifier)
                            .submitGeotechnicalInspection(inspection);

                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Geotechnical Inspection submitted and signed off!'),
                              backgroundColor: AppColors.riskLow,
                            ),
                          );
                          context.pop();
                        }
                      },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentLight, size: 20),
          const SizedBox(width: 8),
          Text(title, style: AppTypography.heading3),
        ],
      ),
    );
  }

  Widget _buildIncidentSnapshot(IncidentReportEntity inc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.riskCritical.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(inc.id, style: AppTypography.caption.copyWith(color: AppColors.accentLight)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.riskCritical.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  inc.severity,
                  style: const TextStyle(color: AppColors.riskCritical, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${inc.district}, ${inc.state} — ${inc.landmark ?? "Road Section"}', style: AppTypography.heading3),
          const SizedBox(height: 4),
          Text('Citizen Report: ${inc.description}', style: AppTypography.bodySmall),
          if (inc.aiAnalysis != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, size: 14, color: AppColors.accentLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'AI Computer Vision: ${inc.aiAnalysis!.summary} (Confidence ${(inc.aiAnalysis!.confidenceScore * 100).toInt()}%)',
                      style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.caption),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: AppTypography.heading3.copyWith(color: AppColors.accentLight),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.surfaceLight,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: AppTypography.caption),
        value: value,
        activeThumbColor: AppColors.accent,
        contentPadding: EdgeInsets.zero,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTypography.caption,
          border: InputBorder.none,
        ),
        dropdownColor: AppColors.surfaceLight,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
