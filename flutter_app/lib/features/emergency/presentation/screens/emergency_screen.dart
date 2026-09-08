import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';
import 'package:ner_landslideguard/core/widgets/sync_status_pill_widget.dart';
import 'package:ner_landslideguard/features/emergency/domain/entities/emergency_sos_entity.dart';
import 'package:ner_landslideguard/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:ner_landslideguard/features/emergency/presentation/widgets/evacuation_shelter_tile.dart';
import 'package:ner_landslideguard/features/emergency/presentation/widgets/mcda_triage_incident_tile.dart';
import 'package:ner_landslideguard/features/emergency/presentation/widgets/sos_panic_button.dart';
import 'package:ner_landslideguard/features/emergency/presentation/widgets/sos_trigger_modal.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openSosModal() {
    showDialog(
      context: context,
      builder: (_) => const SosTriggerModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emergencyStateProvider);

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
            Text('Emergency SOS & MCDA Triage', style: AppTypography.heading3),
            Text(
              'NDRF / SDRF Multi-Criteria Prioritizer',
              style: AppTypography.caption.copyWith(color: AppColors.riskCritical),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Emergency Queue',
            icon: const Icon(Icons.refresh, color: AppColors.accentLight),
            onPressed: () => ref.read(emergencyStateProvider.notifier).loadEmergencyData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.riskCritical,
          indicatorWeight: 3,
          labelColor: AppColors.riskCritical,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            const Tab(icon: Icon(Icons.sos_rounded, size: 18), text: 'CITIZEN SOS'),
            Tab(
              icon: const Icon(Icons.emergency_rounded, size: 18),
              text: 'MCDA TRIAGE (${state.emergencies.length})',
            ),
            Tab(
              icon: const Icon(Icons.night_shelter_rounded, size: 18),
              text: 'SHELTERS (${state.shelters.length})',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Satellite Sync Indicator
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SyncStatusPillWidget(),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Citizen SOS Distress Hub
                  _buildCitizenSosTab(state),

                  // Tab 2: Authority MCDA Prioritized Triage Queue
                  _buildMcdaTriageTab(state),

                  // Tab 3: Evacuation Shelters & Helipads
                  _buildSheltersTab(state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: CITIZEN SOS
  Widget _buildCitizenSosTab(EmergencyState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Active SOS Status Tracker Banner (if user triggered SOS)
          if (state.activeUserSos != null) ...[
            _buildActiveUserSosCard(state.activeUserSos!),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 10),
          Text(
            'EMERGENCY DISTRESS BEACON',
            style: AppTypography.heading3.copyWith(color: AppColors.riskCritical, letterSpacing: 1.1),
          ),
          const SizedBox(height: 6),
          Text(
            'Press the button below to immediately broadcast your GPS location and multi-criteria situation report to NDRF mountain teams.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Big Pulsing SOS Button
          SosPanicButton(
            isSubmitting: state.isSubmittingSos,
            onTap: _openSosModal,
          ),
          const SizedBox(height: 24),

          // GPS Telemetry Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.my_location_rounded, size: 16, color: AppColors.accentLight),
                const SizedBox(width: 8),
                Text(
                  'GPS: 27.5890° N, 91.8620° E (Tawang, Arunachal Pradesh)',
                  style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Helplines
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Emergency Mountain Control Helplines', style: AppTypography.heading3.copyWith(fontSize: 14)),
          ),
          const SizedBox(height: 10),

          _buildHelplineRow('NDRF National Disaster Helpline', '1078', Icons.phone_in_talk_rounded),
          _buildHelplineRow('State Disaster Management (SDMA)', '1070', Icons.support_agent_rounded),
          _buildHelplineRow('District Disaster Control Room (DDMA)', '1077', Icons.location_city_rounded),
          _buildHelplineRow('Emergency National Hotline', '112', Icons.local_police_rounded),
        ],
      ),
    );
  }

  Widget _buildActiveUserSosCard(EmergencySosEntity sos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.riskCritical.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.riskCritical, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.riskCritical, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ACTIVE DISTRESS SIGNAL BROADCASTING', style: AppTypography.heading3.copyWith(color: AppColors.riskCritical, fontSize: 13)),
                    Text('Tracking ID: ${sos.id}', style: AppTypography.caption),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Clear SOS Banner',
                icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                onPressed: () => ref.read(emergencyStateProvider.notifier).clearUserSos(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text('Assigned Rescue Unit: ${sos.dispatchedUnit}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Step Progress Tracker
          _buildSosProgressTracker(sos.status),
        ],
      ),
    );
  }

  Widget _buildSosProgressTracker(String status) {
    final steps = ['DISPATCHED', 'RESCUE_IN_PROGRESS', 'RESOLVED'];
    final currentIndex = steps.indexOf(status).clamp(0, steps.length - 1);

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isPassed = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isPassed ? AppColors.riskCritical : AppColors.surfaceLight,
            ),
          );
        } else {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex <= currentIndex;
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.riskCritical : AppColors.surfaceLight,
              border: Border.all(color: isCompleted ? AppColors.riskCritical : AppColors.divider),
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text('${stepIndex + 1}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          );
        }
      }),
    );
  }

  Widget _buildHelplineRow(String name, String phone, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.accentLight),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  Text('Toll-Free Emergency Number', style: AppTypography.caption.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.riskCritical.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              phone,
              style: const TextStyle(color: AppColors.riskCritical, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: MCDA TRIAGE QUEUE
  Widget _buildMcdaTriageTab(EmergencyState state) {
    final filtered = state.sortedAndFilteredEmergencies;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(emergencyStateProvider.notifier).loadEmergencyData();
      },
      color: AppColors.riskCritical,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips
            Row(
              children: [
                _buildFilterChip('ALL', 'ALL (${state.emergencies.length})', state.selectedPriorityFilter),
                const SizedBox(width: 6),
                _buildFilterChip('P1', 'P1 AIRLIFT (${state.p1Count})', state.selectedPriorityFilter),
                const SizedBox(width: 6),
                _buildFilterChip('P2', 'P2 GROUND (${state.p2Count})', state.selectedPriorityFilter),
                const SizedBox(width: 6),
                _buildFilterChip('P3', 'P3 CIVIL (${state.p3Count})', state.selectedPriorityFilter),
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
                    Text('No Active Distress Incidents in this category', style: AppTypography.heading3),
                    const SizedBox(height: 4),
                    Text('All sectors currently clear or rescue units operational.', style: AppTypography.caption),
                  ],
                ),
              )
            else
              ...filtered.map((incident) {
                return McdaTriageIncidentTile(
                  incident: incident,
                  onStatusChanged: (newStatus) {
                    ref.read(emergencyStateProvider.notifier).updateIncidentStatus(incident.id, newStatus);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, String currentFilter) {
    final isSelected = currentFilter == filterKey;
    final color = filterKey == 'P1'
        ? AppColors.riskCritical
        : (filterKey == 'P2' ? AppColors.riskHigh : (filterKey == 'P3' ? AppColors.riskModerate : AppColors.accent));

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(emergencyStateProvider.notifier).setPriorityFilter(filterKey),
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
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // TAB 3: EVACUATION SHELTERS
  Widget _buildSheltersTab(EmergencyState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Designated Relief Camps & Helipads', style: AppTypography.heading3),
              Text('${state.shelters.length} Facilities', style: AppTypography.caption.copyWith(color: AppColors.accentLight)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Equipped with standby emergency medical officers, high-altitude food rations, and IAF helicopter landing zones.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          ...state.shelters.map((shelter) => EvacuationShelterTile(shelter: shelter)),
        ],
      ),
    );
  }
}
