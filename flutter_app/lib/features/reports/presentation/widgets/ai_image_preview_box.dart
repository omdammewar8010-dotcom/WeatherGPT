import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/incident_report_entity.dart';

class AiImagePreviewBox extends StatelessWidget {
  final AiImageAnalysisResult? analysis;
  final bool isAnalyzing;

  const AiImagePreviewBox({
    super.key,
    this.analysis,
    this.isAnalyzing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isAnalyzing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentLight),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Vision Hazard Screening...', style: AppTypography.heading3.copyWith(fontSize: 13)),
                  Text('Detecting cracks, debris flows & road obstructions', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (analysis == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppColors.accentLight),
                  const SizedBox(width: 6),
                  Text('AI COMPUTER VISION ASSESSMENT', style: AppTypography.caption.copyWith(color: AppColors.accentLight, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(analysis!.confidenceScore * 100).toStringAsFixed(0)}% CONFIDENCE',
                  style: AppTypography.caption.copyWith(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureTag('Crack Detected', analysis!.crackDetected),
              _buildFeatureTag('Debris Detected', analysis!.debrisDetected),
              _buildFeatureTag('Road Blockage', analysis!.roadObstructionDetected),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            analysis!.summary,
            style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'Note: Computer vision screening acts as supporting evidence alongside geotechnical ground truth.',
            style: AppTypography.bodySmall.copyWith(fontSize: 9, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTag(String label, bool detected) {
    final color = detected ? AppColors.riskCritical : AppColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(detected ? Icons.check_circle_rounded : Icons.cancel_outlined, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: color, fontSize: 10, fontWeight: detected ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
