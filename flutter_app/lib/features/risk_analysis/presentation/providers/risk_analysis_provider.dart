import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/risk_analysis_remote_datasource.dart';
import '../../data/repositories/risk_analysis_repository_impl.dart';
import '../../domain/entities/risk_analysis_entity.dart';
import '../../domain/repositories/risk_analysis_repository.dart';

final riskAnalysisRemoteDataSourceProvider = Provider<RiskAnalysisRemoteDataSource>((ref) {
  return RiskAnalysisRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final riskAnalysisRepositoryProvider = Provider<RiskAnalysisRepository>((ref) {
  return RiskAnalysisRepositoryImpl(ref.watch(riskAnalysisRemoteDataSourceProvider));
});

class RiskAnalysisState {
  final RiskAnalysisEntity? analysis;
  final bool isLoading;
  final String? errorMessage;

  const RiskAnalysisState({
    this.analysis,
    this.isLoading = false,
    this.errorMessage,
  });

  RiskAnalysisState copyWith({
    RiskAnalysisEntity? analysis,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RiskAnalysisState(
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RiskAnalysisNotifier extends StateNotifier<RiskAnalysisState> {
  final RiskAnalysisRepository _repository;

  RiskAnalysisNotifier(this._repository) : super(const RiskAnalysisState()) {
    loadExplainability('ner_ar_tawang_001');
  }

  Future<void> loadExplainability(String locationId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _repository.getExplainability(locationId);
      state = state.copyWith(
        analysis: data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load AI explainability factors: $e',
      );
    }
  }
}

final riskAnalysisStateProvider = StateNotifierProvider<RiskAnalysisNotifier, RiskAnalysisState>((ref) {
  return RiskAnalysisNotifier(ref.watch(riskAnalysisRepositoryProvider));
});
