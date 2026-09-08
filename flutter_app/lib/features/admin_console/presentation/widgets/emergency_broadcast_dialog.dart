import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ner_landslideguard/core/constants/app_constants.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import '../providers/admin_command_provider.dart';

class EmergencyBroadcastDialog extends ConsumerStatefulWidget {
  const EmergencyBroadcastDialog({super.key});

  @override
  ConsumerState<EmergencyBroadcastDialog> createState() => _EmergencyBroadcastDialogState();
}

class _EmergencyBroadcastDialogState extends ConsumerState<EmergencyBroadcastDialog> {
  String _selectedState = 'Arunachal Pradesh';
  String _selectedDistrict = 'Tawang';
  String _severity = 'CRITICAL';
  bool _activateSiren = true;
  bool _sendSmsFallback = true;
  final TextEditingController _titleController = TextEditingController(
    text: 'IMMEDIATE RED ALERT: Sela Pass Debris Flow Imminent',
  );
  final TextEditingController _advisoryController = TextEditingController(
    text: 'NH-13 traffic suspended. Residents in lower Lumla sectors instructed to relocate to designated relief camps immediately.',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _advisoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminCommandStateProvider);

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
                    child: const Icon(Icons.broadcast_on_personal_rounded, color: AppColors.riskCritical, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency Broadcast Station', style: AppTypography.heading3),
                        Text(
                          'Direct Priority Push to Citizens & Field Officers',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.divider, height: 24),

              // State & District Dropdowns
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Target NER State',
                      value: _selectedState,
                      items: AppConstants.nerStates,
                      onChanged: (v) => setState(() => _selectedState = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Target District',
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
              const SizedBox(height: 12),

              // Severity Selector
              Text('ALERT SEVERITY LEVEL', style: AppTypography.caption),
              const SizedBox(height: 6),
              Row(
                children: ['CRITICAL', 'HIGH', 'MODERATE'].map((s) {
                  final isSelected = _severity == s;
                  final color = s == 'CRITICAL'
                      ? AppColors.riskCritical
                      : (s == 'HIGH' ? AppColors.riskHigh : AppColors.riskModerate);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _severity = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? color : AppColors.divider, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s,
                            style: TextStyle(
                              color: isSelected ? color : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Title Field
              TextField(
                controller: _titleController,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Broadcast Alert Title',
                  labelStyle: AppTypography.caption,
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),

              // Advisory Message Field
              TextField(
                controller: _advisoryController,
                maxLines: 3,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Public Safety Directive & Evacuation Advisory',
                  labelStyle: AppTypography.caption,
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),

              // Toggles
              SwitchListTile(
                title: Text('Trigger High-Pitch Device Siren', style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
                subtitle: Text('Bypasses silent mode for urgent threat mitigation', style: AppTypography.caption),
                value: _activateSiren,
                activeThumbColor: AppColors.riskCritical,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _activateSiren = v),
              ),
              SwitchListTile(
                title: Text('SMS Cell-Broadcast Fallback', style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
                subtitle: Text('Transmits emergency SMS via BSNL/Airtel mountain towers', style: AppTypography.caption),
                value: _sendSmsFallback,
                activeThumbColor: AppColors.accent,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _sendSmsFallback = v),
              ),
              const SizedBox(height: 18),

              // Dispatch Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: adminState.isBroadcasting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    adminState.isBroadcasting ? 'DISPATCHING TO SATELLITE & TOWERS...' : 'DISPATCH REGIONAL RED ALERT',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.riskCritical,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: adminState.isBroadcasting
                      ? null
                      : () async {
                          final success = await ref
                              .read(adminCommandStateProvider.notifier)
                              .broadcastEmergencyRedAlert(
                                targetState: _selectedState,
                                targetDistrict: _selectedDistrict,
                                alertTitle: _titleController.text.trim(),
                                severity: _severity,
                                advisoryMessage: _advisoryController.text.trim(),
                                activateSiren: _activateSiren,
                                sendSmsFallback: _sendSmsFallback,
                              );

                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🚨 Broadcast dispatched across $_selectedDistrict ($_selectedState)!'),
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
