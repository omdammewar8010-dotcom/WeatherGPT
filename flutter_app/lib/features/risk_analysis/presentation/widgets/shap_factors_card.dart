import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/prediction_factor_bar.dart';
import '../../domain/entities/risk_analysis_entity.dart';

class ShapFactorsCard extends StatelessWidget {
  final List<FactorContribution> factors;

  const ShapFactorsCard({super.key, required this.factors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CONTRIBUTING RISK FACTORS (SHAP)', style: AppTypography.caption),
              Text(
                'Relative Weight',
                style: AppTypography.caption.copyWith(color: AppColors.accentLight),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: factors.length,
            separatorBuilder: (c, i) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final factor = factors[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PredictionFactorBar(
                    title: '${factor.featureName} (${factor.actualValueFormatted})',
                    percentage: factor.importanceScore,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, top: 1),
                    child: Text(
                      factor.description,
                      style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
