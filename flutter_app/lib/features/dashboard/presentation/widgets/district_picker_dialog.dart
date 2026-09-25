import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/risk_profile_model.dart';
import '../providers/dashboard_provider.dart';

class DistrictPickerDialog extends ConsumerStatefulWidget {
  const DistrictPickerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const DistrictPickerDialog(),
    );
  }

  @override
  ConsumerState<DistrictPickerDialog> createState() => _DistrictPickerDialogState();
}

class _DistrictPickerDialogState extends ConsumerState<DistrictPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Comprehensive Pan-India key locations
  static const List<Map<String, String>> _allIndiaLocations = [
    {'name': 'New Delhi', 'state': 'National Capital Territory', 'region': 'North'},
    {'name': 'Mumbai', 'state': 'Maharashtra', 'region': 'West'},
    {'name': 'Bengaluru', 'state': 'Karnataka', 'region': 'South'},
    {'name': 'Kolkata', 'state': 'West Bengal', 'region': 'East'},
    {'name': 'Chennai', 'state': 'Tamil Nadu', 'region': 'South'},
    {'name': 'Hyderabad', 'state': 'Telangana', 'region': 'South'},
    {'name': 'Pune', 'state': 'Maharashtra', 'region': 'West'},
    {'name': 'Ahmedabad', 'state': 'Gujarat', 'region': 'West'},
    {'name': 'Jaipur', 'state': 'Rajasthan', 'region': 'North'},
    {'name': 'Lucknow', 'state': 'Uttar Pradesh', 'region': 'North'},
    {'name': 'Guwahati', 'state': 'Assam', 'region': 'North East'},
    {'name': 'Srinagar', 'state': 'Jammu & Kashmir', 'region': 'North'},
    {'name': 'Shimla', 'state': 'Himachal Pradesh', 'region': 'North'},
    {'name': 'Kochi', 'state': 'Kerala', 'region': 'South'},
    {'name': 'Bhopal', 'state': 'Madhya Pradesh', 'region': 'Central'},
    {'name': 'Patna', 'state': 'Bihar', 'region': 'East'},
    {'name': 'Bhubaneswar', 'state': 'Odisha', 'region': 'East'},
    {'name': 'Chandigarh', 'state': 'Punjab & Haryana', 'region': 'North'},
    {'name': 'Dehradun', 'state': 'Uttarakhand', 'region': 'North'},
    {'name': 'Visakhapatnam', 'state': 'Andhra Pradesh', 'region': 'South'},
    {'name': 'Indore', 'state': 'Madhya Pradesh', 'region': 'Central'},
    {'name': 'Nagpur', 'state': 'Maharashtra', 'region': 'Central'},
    {'name': 'Surat', 'state': 'Gujarat', 'region': 'West'},
    {'name': 'Varanasi', 'state': 'Uttar Pradesh', 'region': 'North'},
    {'name': 'Amritsar', 'state': 'Punjab', 'region': 'North'},
    {'name': 'Ranchi', 'state': 'Jharkhand', 'region': 'East'},
    {'name': 'Raipur', 'state': 'Chhattisgarh', 'region': 'Central'},
    {'name': 'Goa (Panaji)', 'state': 'Goa', 'region': 'West'},
    {'name': 'Tawang', 'state': 'Arunachal Pradesh', 'region': 'North East'},
    {'name': 'Shillong', 'state': 'Meghalaya', 'region': 'North East'},
    {'name': 'Gangtok', 'state': 'Sikkim', 'region': 'North East'},
    {'name': 'Kohima', 'state': 'Nagaland', 'region': 'North East'},
    {'name': 'Aizawl', 'state': 'Mizoram', 'region': 'North East'},
    {'name': 'Agartala', 'state': 'Tripura', 'region': 'North East'},
    {'name': 'Imphal', 'state': 'Manipur', 'region': 'North East'},
    {'name': 'Leh', 'state': 'Ladakh', 'region': 'North'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectLocation(String locationName) {
    Navigator.of(context).pop();
    ref.read(dashboardStateProvider.notifier).loadRiskProfile(locationName);
  }

  @override
  Widget build(BuildContext context) {
    final currentSelected = ref.watch(dashboardStateProvider).selectedDistrict;

    final filtered = _allIndiaLocations.where((loc) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return loc['name']!.toLowerCase().contains(query) ||
          loc['state']!.toLowerCase().contains(query) ||
          loc['region']!.toLowerCase().contains(query);
    }).toList();

    final isCustomQuery = _searchQuery.trim().isNotEmpty &&
        !_allIndiaLocations.any((l) => l['name']!.toLowerCase() == _searchQuery.trim().toLowerCase());

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detect Weather for Any Location', style: AppTypography.heading3),
                  Text(
                    'Search any city, district, or town across India',
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
          const SizedBox(height: 12),

          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search any Indian city, district, or town...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentLight),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                _selectLocation(val.trim());
              }
            },
          ),
          const SizedBox(height: 12),

          // Auto-detect GPS button
          InkWell(
            onTap: () => _selectLocation('New Delhi (GPS Detected)'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, color: AppColors.accentLight, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-Detect My Current GPS Location',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.accentLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Acquires coordinates for instant hyperlocal Doppler radar & NWP forecast',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.accentLight),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Custom typed location option (if not matching exactly)
          if (isCustomQuery) ...[
            InkWell(
              onTap: () => _selectLocation(_searchQuery.trim()),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentLight.withValues(alpha: 0.15),
                      AppColors.surfaceLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: AppColors.accentLight, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detect Weather for "${_searchQuery.trim()}"',
                            style: AppTypography.heading3.copyWith(fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            'WeatherGPT AI will dynamically synthesize live Doppler & NWP models',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DETECT',
                        style: AppTypography.caption.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          const Divider(),
          const SizedBox(height: 4),

          // Filtered list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filtered.length,
              separatorBuilder: (c, i) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final loc = filtered[index];
                final name = loc['name']!;
                final state = loc['state']!;
                final region = loc['region']!;
                final isSelected = name.toLowerCase() == currentSelected.toLowerCase();
                final profile = RiskProfileModel.getProfileForLocation(name);
                final riskColor = AppColors.getRiskColor(profile.riskScore);

                return InkWell(
                  onTap: () => _selectLocation(name),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.location_on_outlined,
                              size: 18,
                              color: isSelected ? AppColors.accentLight : AppColors.textMuted,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: AppTypography.heading3.copyWith(
                                    fontSize: 14,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '$state • $region Zone',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${profile.riskLevel} (${profile.riskScore})',
                            style: AppTypography.caption.copyWith(
                              color: riskColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
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
      ),
    );
  }
}
