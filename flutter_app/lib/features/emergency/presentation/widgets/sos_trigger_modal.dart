import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ner_landslideguard/core/constants/app_constants.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/features/emergency/domain/entities/emergency_sos_entity.dart';
import 'package:ner_landslideguard/features/emergency/presentation/providers/emergency_provider.dart';

class SosTriggerModal extends ConsumerStatefulWidget {
  const SosTriggerModal({super.key});

  @override
  ConsumerState<SosTriggerModal> createState() => _SosTriggerModalState();
}

class _SosTriggerModalState extends ConsumerState<SosTriggerModal> {
  String _selectedState = 'Arunachal Pradesh';
  String _selectedDistrict = 'Tawang';
  int _trappedCount = 0;
  bool _medicalEmergency = false;
  bool _roadCutOff = true;
  int _vulnerableCount = 0;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(text: 'Omkar Damle');
  final TextEditingController _phoneController = TextEditingController(text: '+91 98765 43210');

  @override
  void dispose() {
    _notesController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _estimatedMcdaScore {
    return EmergencyMcdaCalculator.computeScore(
      trappedCount: _trappedCount,
      medicalEmergency: _medicalEmergency,
      roadCutOff: _roadCutOff,
      vulnerableDependents: _vulnerableCount,
    );
  }

  String get _estimatedPriorityLevel {
    return EmergencyMcdaCalculator.getPriorityLevel(_estimatedMcdaScore);
  }

  @override
  Widget build(BuildContext context) {
    final emergencyState = ref.watch(emergencyStateProvider);
    final score = _estimatedMcdaScore;
    final priority = _estimatedPriorityLevel;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.riskCritical.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sos_rounded, color: AppColors.riskCritical, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency SOS Distress Dispatch', style: AppTypography.heading3),
                        Text(
                          'Direct Priority Link to NDRF / SDRF Mountain Taskforce',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.divider, height: 24),

              // Realtime MCDA Preview Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: priority.startsWith('P1')
                        ? AppColors.riskCritical
                        : (priority.startsWith('P2') ? AppColors.riskHigh : AppColors.riskModerate),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CALCULATED MCDA PRIORITY', style: AppTypography.caption),
                        Text(
                          priority.replaceAll('_', ' '),
                          style: AppTypography.bodySmall.copyWith(
                            color: priority.startsWith('P1')
                                ? AppColors.riskCritical
                                : (priority.startsWith('P2') ? AppColors.riskHigh : AppColors.riskModerate),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${score.toInt()}/100',
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Region Dropdowns
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'State',
                      value: _selectedState,
                      items: AppConstants.nerStates,
                      onChanged: (v) => setState(() => _selectedState = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                      label: 'District',
                      value: _selectedDistrict,
                      items: const [
                        'Tawang', 'Gangtok', 'Shillong', 'Aizawl',
                        'Kohima', 'Imphal', 'Guwahati', 'Agartala'
                      ],
                      onChanged: (v) => setState(() => _selectedDistrict = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Trapped Persons Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trapped Individuals Under Debris', style: AppTypography.bodySmall),
                        Text('Estimated count requiring extraction', style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                        onPressed: _trappedCount > 0 ? () => setState(() => _trappedCount--) : null,
                      ),
                      Text('$_trappedCount', style: AppTypography.heading3),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.riskCritical),
                        onPressed: () => setState(() => _trappedCount++),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Vulnerable Dependents Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Elderly / Infant Dependents', style: AppTypography.bodySmall),
                        Text('Non-ambulatory family members', style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                        onPressed: _vulnerableCount > 0 ? () => setState(() => _vulnerableCount--) : null,
                      ),
                      Text('$_vulnerableCount', style: AppTypography.heading3),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.accentLight),
                        onPressed: () => setState(() => _vulnerableCount++),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Switches
              SwitchListTile(
                title: Text('Critical Medical Trauma / Oxygen Need', style: AppTypography.bodySmall),
                subtitle: Text('Directs emergency paramedic or air-ambulance', style: AppTypography.caption),
                value: _medicalEmergency,
                activeThumbColor: AppColors.riskCritical,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _medicalEmergency = v),
              ),
              SwitchListTile(
                title: Text('Road Access Completely Severed', style: AppTypography.bodySmall),
                subtitle: Text('Debris blockage prevents vehicle entry (Aerial/Ropeway needed)', style: AppTypography.caption),
                value: _roadCutOff,
                activeThumbColor: AppColors.riskHigh,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _roadCutOff = v),
              ),
              const SizedBox(height: 10),

              // Notes Field
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Landmark / Immediate Situation Notes',
                  labelStyle: AppTypography.caption,
                  hintText: 'e.g., Near Sela Pass curve, ground floor submerged in mud',
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 18),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: emergencyState.isSubmittingSos
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    emergencyState.isSubmittingSos ? 'TRANSMITTING SOS SIGNAL...' : 'TRANSMIT RESCUE SOS NOW',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.riskCritical,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: emergencyState.isSubmittingSos
                      ? null
                      : () async {
                          final result = await ref.read(emergencyStateProvider.notifier).submitCitizenSos(
                                reporterName: _nameController.text.trim(),
                                reporterPhone: _phoneController.text.trim(),
                                district: _selectedDistrict,
                                stateName: _selectedState,
                                latitude: 27.5890,
                                longitude: 91.8620,
                                trappedCount: _trappedCount,
                                medicalEmergency: _medicalEmergency,
                                roadCutOff: _roadCutOff,
                                vulnerableDependents: _vulnerableCount,
                                notes: _notesController.text.trim().isEmpty
                                    ? 'Emergency SOS via LandslideGuard Citizen App'
                                    : _notesController.text.trim(),
                              );

                          if (context.mounted && result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🚨 SOS Transmitted! Dispatch: ${result.dispatchedUnit}'),
                                backgroundColor: AppColors.riskCritical,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
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
