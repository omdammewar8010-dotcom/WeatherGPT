import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ner_landslideguard/core/constants/app_constants.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/features/roads_overwatch/presentation/providers/roads_provider.dart';

class ReportRoadBlockageDialog extends ConsumerStatefulWidget {
  const ReportRoadBlockageDialog({super.key});

  @override
  ConsumerState<ReportRoadBlockageDialog> createState() => _ReportRoadBlockageDialogState();
}

class _ReportRoadBlockageDialogState extends ConsumerState<ReportRoadBlockageDialog> {
  String _selectedHighway = 'NH-13 (Trans-Arunachal Highway)';
  String _selectedState = 'Arunachal Pradesh';
  String _selectedDistrict = 'Tawang';
  String _status = 'TOTAL_BLOCKAGE';
  final TextEditingController _sectionController = TextEditingController(text: 'Sela Pass KM 48');
  final TextEditingController _causeController = TextEditingController(text: 'Large boulders and mud avalanche blocked both lanes.');
  final TextEditingController _detourController = TextEditingController(text: 'Dirang - Lumla 4x4 Old Track');

  @override
  void dispose() {
    _sectionController.dispose();
    _causeController.dispose();
    _detourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roadsState = ref.watch(roadsStateProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.riskHigh.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.traffic_rounded, color: AppColors.riskHigh, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Report Road / Highway Blockage', style: AppTypography.heading3),
                        Text('Direct Real-Time Notification to BRO & Commuters', style: AppTypography.caption),
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

              // Highway Dropdown
              _buildDropdown(
                label: 'National Highway Corridor',
                value: _selectedHighway,
                items: const [
                  'NH-13 (Trans-Arunachal Highway)',
                  'NH-10 (Siliguri - Gangtok Lifeline)',
                  'NH-29 (Dimapur - Kohima Corridor)',
                  'NH-54 (Silchar - Aizawl Arterial)',
                  'NH-37 (Assam - Manipur Highway)',
                ],
                onChanged: (v) => setState(() => _selectedHighway = v!),
              ),
              const SizedBox(height: 10),

              // State & District Dropdowns
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
              const SizedBox(height: 10),

              // Section input
              TextField(
                controller: _sectionController,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Highway Section / Chainage KM',
                  labelStyle: AppTypography.caption,
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),

              // Blockage Status
              Text('BLOCKAGE SEVERITY', style: AppTypography.caption),
              const SizedBox(height: 6),
              Row(
                children: ['TOTAL_BLOCKAGE', 'PARTIALLY_BLOCKED', 'VULNERABLE'].map((s) {
                  final isSelected = _status == s;
                  final color = s == 'TOTAL_BLOCKAGE'
                      ? AppColors.riskCritical
                      : (s == 'PARTIALLY_BLOCKED' ? AppColors.riskHigh : AppColors.riskModerate);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _status = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? color : AppColors.divider),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s.replaceAll('_', ' '),
                            style: TextStyle(
                              color: isSelected ? color : AppColors.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Cause Input
              TextField(
                controller: _causeController,
                maxLines: 2,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Blockage Cause Description',
                  labelStyle: AppTypography.caption,
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),

              // Detour Input
              TextField(
                controller: _detourController,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Recommended Alternate Detour Route',
                  labelStyle: AppTypography.caption,
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 18),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: roadsState.isReportingBlockage
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    roadsState.isReportingBlockage ? 'DISPATCHING REPORT...' : 'SUBMIT ROAD OVERWATCH REPORT',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.riskHigh,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: roadsState.isReportingBlockage
                      ? null
                      : () async {
                          final success = await ref.read(roadsStateProvider.notifier).reportBlockage(
                                highwayName: _selectedHighway,
                                section: _sectionController.text.trim(),
                                district: _selectedDistrict,
                                stateName: _selectedState,
                                status: _status,
                                cause: _causeController.text.trim(),
                                alternateDetour: _detourController.text.trim(),
                              );

                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🛣️ Road blockage report broadcast to BRO & commuters!'),
                                backgroundColor: AppColors.riskHigh,
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
            child: Text(
              item,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
