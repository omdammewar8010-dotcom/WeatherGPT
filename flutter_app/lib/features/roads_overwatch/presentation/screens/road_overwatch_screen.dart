import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ner_landslideguard/core/constants/app_constants.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/core/widgets/sync_status_pill_widget.dart';
import 'package:ner_landslideguard/features/roads_overwatch/presentation/providers/roads_provider.dart';
import 'package:ner_landslideguard/features/roads_overwatch/presentation/widgets/highway_corridor_card.dart';
import 'package:ner_landslideguard/features/roads_overwatch/presentation/widgets/historical_event_card.dart';
import 'package:ner_landslideguard/features/roads_overwatch/presentation/widgets/report_road_blockage_dialog.dart';

class RoadOverwatchScreen extends ConsumerStatefulWidget {
  const RoadOverwatchScreen({super.key});

  @override
  ConsumerState<RoadOverwatchScreen> createState() => _RoadOverwatchScreenState();
}

class _RoadOverwatchScreenState extends ConsumerState<RoadOverwatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openReportBlockageModal() {
    showDialog(
      context: context,
      builder: (_) => const ReportRoadBlockageDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roadsState = ref.watch(roadsStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Highway Overwatch & Historical Catalog', style: AppTypography.heading3),
            Text(
              'Border Roads Organisation (BRO) & GSI Landslide Archive',
              style: AppTypography.caption.copyWith(color: AppColors.accentLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Report Road Blockage',
            icon: const Icon(Icons.add_road_rounded, color: AppColors.riskHigh),
            onPressed: _openReportBlockageModal,
          ),
          IconButton(
            tooltip: 'Refresh Road Telemetry',
            icon: const Icon(Icons.refresh, color: AppColors.accentLight),
            onPressed: () => ref.read(roadsStateProvider.notifier).loadAllRoadData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(
              icon: const Icon(Icons.traffic_rounded, size: 18),
              text: 'HIGHWAY CORRIDORS (${roadsState.corridors.length})',
            ),
            Tab(
              icon: const Icon(Icons.history_edu_rounded, size: 18),
              text: 'GSI ARCHIVE (${roadsState.historicalEvents.length})',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.riskHigh,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_road_rounded),
        label: const Text('REPORT BLOCKAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        onPressed: _openReportBlockageModal,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Sync Pill
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SyncStatusPillWidget(),
            ),

            // 2. Search & State Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search highway, section, or location...',
                        hintStyle: AppTypography.caption,
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                      ),
                      onChanged: (v) => ref.read(roadsStateProvider.notifier).setSearchQuery(v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: DropdownButton<String>(
                      value: roadsState.selectedState,
                      underline: const SizedBox.shrink(),
                      dropdownColor: AppColors.surface,
                      style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                      items: ['ALL', ...AppConstants.nerStates].map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s == 'ALL' ? 'All NER States' : s, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(roadsStateProvider.notifier).setStateFilter(v);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 3. TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Live Highway Corridors
                  _buildHighwayCorridorsTab(roadsState),

                  // Tab 2: GSI Historical Archive
                  _buildHistoricalCatalogTab(roadsState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighwayCorridorsTab(RoadsState state) {
    final filtered = state.filteredCorridors;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(roadsStateProvider.notifier).loadAllRoadData();
      },
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter Chips
            Row(
              children: [
                _buildStatusChip('ALL', 'ALL (${state.corridors.length})', state.statusFilter),
                const SizedBox(width: 6),
                _buildStatusChip('BLOCKED', 'BLOCKED (${state.blockedCorridorsCount})', state.statusFilter),
                const SizedBox(width: 6),
                _buildStatusChip('VULNERABLE', 'VULNERABLE', state.statusFilter),
                const SizedBox(width: 6),
                _buildStatusChip('CLEAR', 'CLEAR (${state.clearCorridorsCount})', state.statusFilter),
              ],
            ),
            const SizedBox(height: 14),

            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.riskLow),
                    const SizedBox(height: 12),
                    Text('No Corridors Matching Filter', style: AppTypography.heading3),
                    const SizedBox(height: 4),
                    Text('All highway sections in this category are operating smoothly.', style: AppTypography.caption),
                  ],
                ),
              )
            else
              ...filtered.map((c) => HighwayCorridorCard(corridor: c)),
            const SizedBox(height: 70), // space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String filterKey, String label, String currentFilter) {
    final isSelected = currentFilter == filterKey;
    final color = filterKey == 'BLOCKED'
        ? AppColors.riskCritical
        : (filterKey == 'VULNERABLE'
            ? AppColors.riskModerate
            : (filterKey == 'CLEAR' ? AppColors.riskLow : AppColors.accent));

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(roadsStateProvider.notifier).setStatusFilter(filterKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : AppColors.divider),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricalCatalogTab(RoadsState state) {
    final filtered = state.filteredHistoricalEvents;
    const years = [null, 2024, 2023, 2022, 2020, 2018];

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(roadsStateProvider.notifier).loadAllRoadData();
      },
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: years.map((y) {
                  final isSelected = state.selectedYear == y;
                  final label = y == null ? 'All Years' : '$y';
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(label, style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      selectedColor: AppColors.accent.withValues(alpha: 0.25),
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.accentLight : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.accentLight : AppColors.divider,
                      ),
                      onSelected: (selected) {
                        ref.read(roadsStateProvider.notifier).setYearFilter(selected ? y : null);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text('No Historical Landslide Records Found', style: AppTypography.heading3),
                    const SizedBox(height: 4),
                    Text('Try adjusting state or year filters.', style: AppTypography.caption),
                  ],
                ),
              )
            else
              ...filtered.map((e) => HistoricalEventCard(event: e)),
            const SizedBox(height: 70), // space for FAB
          ],
        ),
      ),
    );
  }
}
