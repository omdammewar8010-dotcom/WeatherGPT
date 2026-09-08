import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/risk_profile_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

class DashboardState {
  final RiskProfileEntity? riskProfile;
  final String selectedDistrict;
  final bool isLoading;
  final String? errorMessage;
  final bool isOffline;

  const DashboardState({
    this.riskProfile,
    this.selectedDistrict = 'Tawang',
    this.isLoading = false,
    this.errorMessage,
    this.isOffline = false,
  });

  DashboardState copyWith({
    RiskProfileEntity? riskProfile,
    String? selectedDistrict,
    bool? isLoading,
    String? errorMessage,
    bool? isOffline,
  }) {
    return DashboardState(
      riskProfile: riskProfile ?? this.riskProfile,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(const DashboardState()) {
    loadRiskProfile('Tawang');
  }

  Future<void> loadRiskProfile(String district) async {
    state = state.copyWith(isLoading: true, errorMessage: null, selectedDistrict: district);
    try {
      final profile = await _repository.getDistrictRiskProfile(district);
      state = state.copyWith(
        riskProfile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch risk data: $e',
      );
    }
  }

  Future<void> refresh() async {
    await loadRiskProfile(state.selectedDistrict);
  }
}

final dashboardStateProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(dashboardRepositoryProvider));
});
