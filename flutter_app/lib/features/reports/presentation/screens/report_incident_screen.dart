import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/incident_report_entity.dart';
import '../providers/report_provider.dart';
import '../widgets/ai_image_preview_box.dart';
import '../widgets/report_step_indicator.dart';

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  int _currentStep = 1;

  // Form State
  ReportCategory _selectedCategory = ReportCategory.landslide;
  String _selectedSeverity = 'HIGH';
  bool _hasMedia = false;
  bool _isAnalyzingMedia = false;
  AiImageAnalysisResult? _aiAnalysisResult;

  final double _currentLat = 27.586;
  final double _currentLng = 91.859;
  final String _currentState = 'Arunachal Pradesh';
  final String _currentDistrict = 'Tawang';

  final TextEditingController _landmarkController = TextEditingController(text: 'NH-13 Near KM 14 (Lumla Road)');
  final TextEditingController _descriptionController = TextEditingController(
    text: 'Continuous slope displacement observed after rainfall. Small rocks and mud rolling onto highway.',
  );

  @override
  void dispose() {
    _landmarkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _simulatePhotoCapture() async {
    setState(() {
      _hasMedia = true;
      _isAnalyzingMedia = true;
    });

    // Simulate Computer Vision inference
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isAnalyzingMedia = false;
        _aiAnalysisResult = const AiImageAnalysisResult(
          crackDetected: true,
          debrisDetected: true,
          roadObstructionDetected: true,
          confidenceScore: 0.93,
          summary: 'Computer Vision identified active mudflow debris and potential slope detachment.',
        );
      });
    }
  }

  void _handleSubmit() async {
    final authState = ref.read(authStateProvider);
    final user = authState.user;

    final reportId = 'LR-2026-${(DateTime.now().millisecondsSinceEpoch % 900000 + 100000)}';

    final newReport = IncidentReportEntity(
      id: reportId,
      reporterId: user?.id ?? 'usr_demo',
      reporterName: user?.fullName ?? 'Citizen Reporter',
      reporterPhone: user?.phone ?? '+91 98765 43210',
      category: _selectedCategory,
      severity: _selectedSeverity,
      latitude: _currentLat,
      longitude: _currentLng,
      state: _currentState,
      district: _currentDistrict,
      landmark: _landmarkController.text.trim(),
      description: _descriptionController.text.trim(),
      mediaUrls: _hasMedia ? ['https://storage.googleapis.com/ner-guard-demo/$reportId.jpg'] : [],
      status: 'UNDER_REVIEW',
      isOfflinePending: false,
      aiAnalysis: _aiAnalysisResult,
      createdAt: 'Just now',
    );

    final result = await ref.read(reportStateProvider.notifier).submitNewReport(newReport);

    if (result != null && mounted) {
      _showSuccessDialog(result);
    }
  }

  void _showSuccessDialog(IncidentReportEntity report) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Report Submitted',
                style: AppTypography.heading2.copyWith(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your geo-tagged incident report has been registered in the NER Disaster Response Queue.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REPORT IDENTIFIER', style: AppTypography.caption.copyWith(fontSize: 9)),
                  Text(
                    report.id,
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.accentLight,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Initial Status:', style: AppTypography.bodySmall),
                      Text(
                        report.status.replaceAll('_', ' '),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.goNamed(RouteNames.reportStatus);
            },
            child: const Text('View All My Reports'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🚨 Report Hazard Incident'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'View Report Statuses',
            onPressed: () => context.pushNamed(RouteNames.reportStatus),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 6-Step Progress Indicator
              ReportStepIndicator(currentStep: _currentStep),
              const SizedBox(height: 20),

              // Step 1: Category Selection
              if (_currentStep == 1) ...[
                Text('1. WHAT DID YOU OBSERVE?', style: AppTypography.heading3),
                const SizedBox(height: 4),
                Text('Select the primary slope hazard or obstruction observed on-site.', style: AppTypography.bodySmall),
                const SizedBox(height: 16),
                _buildCategoryTile(ReportCategory.landslide, 'Landslide / Debris Flow', Icons.landslide_rounded),
                _buildCategoryTile(ReportCategory.groundCrack, 'Ground / Slope Crack', Icons.grain_rounded),
                _buildCategoryTile(ReportCategory.rockfall, 'Rockfall / Boulder Roll', Icons.terrain_rounded),
                _buildCategoryTile(ReportCategory.roadBlockage, 'Road / Highway Blockage', Icons.alt_route_rounded),
                _buildCategoryTile(ReportCategory.soilErosion, 'Severe Soil Erosion', Icons.waves_rounded),
                _buildCategoryTile(ReportCategory.other, 'Other Slope Anomaly', Icons.report_problem_rounded),
              ],

              // Step 2: Severity Selection
              if (_currentStep == 2) ...[
                Text('2. OBSERVED SEVERITY LEVEL', style: AppTypography.heading3),
                const SizedBox(height: 4),
                Text('Indicate how severely traffic or local safety is impacted.', style: AppTypography.bodySmall),
                const SizedBox(height: 16),
                _buildSeverityCard('CRITICAL', 'Road completely blocked / structure in immediate collapse risk', AppColors.riskCritical),
                _buildSeverityCard('HIGH', 'Partial lane blockage / active continuous rock or mud roll', AppColors.riskHigh),
                _buildSeverityCard('MODERATE', 'Noticeable ground fissure / slow creep on embankment', AppColors.riskModerate),
                _buildSeverityCard('LOW', 'Early hairline cracks / minor side ditch siltation', AppColors.riskLow),
              ],

              // Step 3: Evidence Capture & AI Vision
              if (_currentStep == 3) ...[
                Text('3. UPLOAD VISUAL EVIDENCE', style: AppTypography.heading3),
                const SizedBox(height: 4),
                Text('Geo-tagged photos/videos trigger AI computer vision hazard screening.', style: AppTypography.bodySmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _simulatePhotoCapture,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Take Photo'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _simulatePhotoCapture,
                        icon: const Icon(Icons.videocam_outlined),
                        label: const Text('Record Video'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_hasMedia) ...[
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.image_rounded, size: 48, color: AppColors.accentLight),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '1 Photo Captured ✓',
                              style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AiImagePreviewBox(
                    analysis: _aiAnalysisResult,
                    isAnalyzing: _isAnalyzingMedia,
                  ),
                ],
              ],

              // Step 4: Location Detection
              if (_currentStep == 4) ...[
                Text('4. GPS LOCATION & LANDMARK', style: AppTypography.heading3),
                const SizedBox(height: 4),
                Text('Coordinates automatically detected from device sensor.', style: AppTypography.bodySmall),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location_rounded, color: AppColors.accentLight, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GPS: $_currentLat, $_currentLng (Accuracy ±4m)',
                              style: AppTypography.heading3.copyWith(fontSize: 13),
                            ),
                            Text(
                              'Sector: $_currentDistrict, $_currentState',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _landmarkController,
                  decoration: const InputDecoration(
                    labelText: 'Highway Milestone / Local Landmark',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
              ],

              // Step 5: Description & Notes
              if (_currentStep == 5) ...[
                Text('5. CONTEXTUAL OBSERVATION', style: AppTypography.heading3),
                const SizedBox(height: 4),
                Text('Describe traffic impact, weather intensity, or immediate danger.', style: AppTypography.bodySmall),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Observations',
                    alignLabelWithHint: true,
                  ),
                ),
              ],

              // Step 6: Final Review & Submit
              if (_currentStep == 6) ...[
                Text('6. REVIEW & SUBMIT HAZARD REPORT', style: AppTypography.heading3),
                const SizedBox(height: 4),
                Text('Confirm report summary before publishing to response queue.', style: AppTypography.bodySmall),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Category', _selectedCategory.displayName),
                      const Divider(),
                      _buildSummaryRow('Severity', _selectedSeverity),
                      const Divider(),
                      _buildSummaryRow('Landmark', _landmarkController.text),
                      const Divider(),
                      _buildSummaryRow('GPS Sector', '$_currentDistrict, $_currentState'),
                      const Divider(),
                      _buildSummaryRow('Media Attached', _hasMedia ? '1 Photo + AI Screening' : 'None'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Step Navigation Buttons
              Row(
                children: [
                  if (_currentStep > 1) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: reportState.isSubmitting
                          ? null
                          : () {
                              if (_currentStep < 6) {
                                setState(() => _currentStep++);
                              } else {
                                _handleSubmit();
                              }
                            },
                      child: reportState.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_currentStep == 6 ? 'Submit Incident Report' : 'Next Step →'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(ReportCategory cat, String title, IconData icon) {
    final isSelected = _selectedCategory == cat;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = cat),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.accentLight : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.heading3.copyWith(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.accentLight : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityCard(String level, String desc, Color color) {
    final isSelected = _selectedSeverity == level;
    return InkWell(
      onTap: () => setState(() => _selectedSeverity = level),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : AppColors.surfaceBorder, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level, style: AppTypography.heading3.copyWith(fontSize: 13, color: color)),
                  const SizedBox(height: 2),
                  Text(desc, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: AppTypography.heading3.copyWith(fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
