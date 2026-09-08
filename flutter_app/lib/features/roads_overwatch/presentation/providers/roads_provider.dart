import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ner_landslideguard/features/roads_overwatch/data/repositories/roads_repository_impl.dart';
import 'package:ner_landslideguard/features/roads_overwatch/domain/entities/road_corridor_entity.dart';
import 'package:ner_landslideguard/features/roads_overwatch/domain/repositories/roads_repository.dart';

final roadsRepositoryProvider = Provider<RoadsRepository>((ref) {
  return RoadsRepositoryImpl();
});

class RoadsState {
  final List<RoadCorridorEntity> corridors;
  final List<HistoricalLandslideEventEntity> historicalEvents;
  final String statusFilter; // "ALL", "BLOCKED", "VULNERABLE", "CLEAR"
  final String selectedState; // "ALL" or specific state
  final int? selectedYear; // null or specific year
  final String searchQuery;
  final bool isLoading;
  final bool isReportingBlockage;
  final String? errorMessage;

  const RoadsState({
    this.corridors = const [],
    this.historicalEvents = const [],
    this.statusFilter = 'ALL',
    this.selectedState = 'ALL',
    this.selectedYear,
    this.searchQuery = '',
    this.isLoading = false,
    this.isReportingBlockage = false,
    this.errorMessage,
  });

  List<RoadCorridorEntity> get filteredCorridors {
    return corridors.where((c) {
      if (statusFilter == 'BLOCKED' && !c.isBlocked) return false;
      if (statusFilter == 'VULNERABLE' && c.status != 'VULNERABLE') return false;
      if (statusFilter == 'CLEAR' && c.status != 'CLEAR') return false;

      if (selectedState != 'ALL' &&
          c.state.toLowerCase() != selectedState.toLowerCase()) {
        return false;
      }

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matches = c.highwayName.toLowerCase().contains(query) ||
            c.section.toLowerCase().contains(query) ||
            c.district.toLowerCase().contains(query);
        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  List<HistoricalLandslideEventEntity> get filteredHistoricalEvents {
    return historicalEvents.where((e) {
      if (selectedState != 'ALL' &&
          e.state.toLowerCase() != selectedState.toLowerCase()) {
        return false;
      }
      if (selectedYear != null && e.year != selectedYear) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matches = e.locationName.toLowerCase().contains(query) ||
            e.highwaySevered.toLowerCase().contains(query) ||
            e.district.toLowerCase().contains(query);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  int get blockedCorridorsCount => corridors.where((c) => c.isBlocked).length;
  int get clearCorridorsCount => corridors.where((c) => c.status == 'CLEAR').length;

  RoadsState copyWith({
    List<RoadCorridorEntity>? corridors,
    List<HistoricalLandslideEventEntity>? historicalEvents,
    String? statusFilter,
    String? selectedState,
    int? selectedYear,
    String? searchQuery,
    bool? isLoading,
    bool? isReportingBlockage,
    String? errorMessage,
  }) {
    return RoadsState(
      corridors: corridors ?? this.corridors,
      historicalEvents: historicalEvents ?? this.historicalEvents,
      statusFilter: statusFilter ?? this.statusFilter,
      selectedState: selectedState ?? this.selectedState,
      selectedYear: selectedYear,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isReportingBlockage: isReportingBlockage ?? this.isReportingBlockage,
      errorMessage: errorMessage,
    );
  }
}

class RoadsNotifier extends StateNotifier<RoadsState> {
  final RoadsRepository _repository;

  RoadsNotifier(this._repository) : super(const RoadsState()) {
    loadAllRoadData();
  }

  Future<void> loadAllRoadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final corridors = await _repository.getRoadCorridors();
      final historical = await _repository.getHistoricalLandslides();
      state = state.copyWith(
        corridors: corridors,
        historicalEvents: historical,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load road overwatch data: $e',
      );
    }
  }

  void setStatusFilter(String filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setStateFilter(String stateName) {
    state = state.copyWith(selectedState: stateName);
  }

  void setYearFilter(int? year) {
    state = state.copyWith(selectedYear: year);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> reportBlockage({
    required String highwayName,
    required String section,
    required String district,
    required String stateName,
    required String status,
    required String cause,
    String? alternateDetour,
  }) async {
    state = state.copyWith(isReportingBlockage: true, errorMessage: null);
    try {
      final report = RoadCorridorEntity(
        corridorId: 'ROAD-NEW-${DateTime.now().millisecondsSinceEpoch % 1000}',
        highwayName: highwayName,
        section: section,
        district: district,
        state: stateName,
        status: status,
        blockageCause: cause,
        clearingProgressPct: 0,
        estimatedReopeningHours: 12,
        alternateDetour: alternateDetour,
        lastReported: 'Just now',
      );

      final created = await _repository.reportRoadBlockage(report);
      state = state.copyWith(
        isReportingBlockage: false,
        corridors: [created, ...state.corridors],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isReportingBlockage: false,
        errorMessage: 'Failed to submit blockage report: $e',
      );
      return false;
    }
  }
}

final roadsStateProvider =
    StateNotifierProvider<RoadsNotifier, RoadsState>((ref) {
  final repo = ref.watch(roadsRepositoryProvider);
  return RoadsNotifier(repo);
});
