import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/risk_score_dial.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../providers/risk_analysis_provider.dart';
import '../widgets/plain_language_reasons_card.dart';
import '../widgets/shap_factors_card.dart';
import '../widgets/two_layer_model_card.dart';

class RiskAnalysisScreen extends ConsumerWidget {
  final String? locationId;

  const RiskAnalysisScreen({super.key, this.locationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(riskAnalysisStateProvider);
    final analysis = state.analysis;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Risk Explainability', style: AppTypography.heading3.copyWith(fontSize: 15)),
            Text(
              analysis?.locationName ?? 'Decision Support Engine',
              style: AppTypography.caption.copyWith(color: AppColors.accentLight, fontSize: 10),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Re-run SHAP Analysis',
            onPressed: () => ref
                .read(riskAnalysisStateProvider.notifier)
                .loadExplainability(locationId ?? 'ner_ar_tawang_001'),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading || analysis == null
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ShimmerSkeleton(width: double.infinity, height: 200, borderRadius: 16),
                    SizedBox(height: 16),
                    ShimmerSkeleton(width: double.infinity, height: 180, borderRadius: 12),
                    SizedBox(height: 16),
                    ShimmerSkeleton(width: double.infinity, height: 260, borderRadius: 12),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Overview Hero Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.getRiskColor(analysis.finalRiskScore).withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('EVALUATION CONFIDENCE', style: AppTypography.caption),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.riskLow.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${analysis.confidencePercent}% HIGH CONFIDENCE',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.riskLow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: RiskScoreDial(
                              score: analysis.finalRiskScore,
                              size: 175,
                              subtitle: '${analysis.district}, ${analysis.state}',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMiniBadge('Data Quality', analysis.dataQuality, AppColors.success),
                              const SizedBox(width: 8),
                              _buildMiniBadge('Model', 'Hybrid Ensembled', AppColors.accentLight),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Plain-Language Drivers Card ("Why is the risk high?")
                    PlainLanguageReasonsCard(
                      primaryDrivers: analysis.primaryDrivers,
                      riskScore: analysis.finalRiskScore,
                    ),
                    const SizedBox(height: 16),

                    // Two-Layer AI Hybrid Card
                    TwoLayerModelCard(analysis: analysis),
                    const SizedBox(height: 16),

                    // Contributing Factors (SHAP Weights)
                    ShapFactorsCard(factors: analysis.factorContributions),
                    const SizedBox(height: 16),

                    // Scientific Transparency Disclaimer
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.accentLight),
                              const SizedBox(width: 6),
                              Text(
                                'SCIENTIFIC & ETHICAL AI TRANSPARENCY',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.accentLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppConstants.scientificDisclaimer,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMiniBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
