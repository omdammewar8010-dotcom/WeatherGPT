import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import 'alert_card.dart';
import 'emergency_button.dart';
import 'incident_card.dart';
import 'location_header.dart';
import 'map_filter_chip.dart';
import 'offline_banner.dart';
import 'prediction_factor_bar.dart';
import 'risk_badge.dart';
import 'risk_score_dial.dart';
import 'weather_stat_card.dart';

class DesignSystemPreviewScreen extends StatefulWidget {
  const DesignSystemPreviewScreen({super.key});

  @override
  State<DesignSystemPreviewScreen> createState() => _DesignSystemPreviewScreenState();
}

class _DesignSystemPreviewScreenState extends State<DesignSystemPreviewScreen> {
  int _currentScore = 87;
  bool _filterRisk = true;
  bool _filterRoads = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System & UI Atoms Catalog'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OfflineBanner(isOffline: true),
              const SizedBox(height: 16),
              const LocationHeader(
                stateName: 'Arunachal Pradesh',
                districtName: 'Tawang',
                village: 'Lumla Sector 4',
                lastUpdated: '4 mins ago',
              ),
              const SizedBox(height: 24),

              Text('1. RISK SCORE DIAL (ANIMATED GAUGE)', style: AppTypography.caption),
              const SizedBox(height: 12),
              Center(
                child: RiskScoreDial(
                  score: _currentScore,
                  size: 200,
                  subtitle: 'High Slope & Rain',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _currentScore = 24),
                    child: const Text('Low (24)'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => setState(() => _currentScore = 48),
                    child: const Text('Mod (48)'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => setState(() => _currentScore = 72),
                    child: const Text('High (72)'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => setState(() => _currentScore = 87),
                    child: const Text('Crit (87)'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text('2. SEMANTIC RISK BADGES', style: AppTypography.caption),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  RiskBadge(score: 18),
                  RiskBadge(score: 45),
                  RiskBadge(score: 68),
                  RiskBadge(score: 92),
                  RiskBadge(level: 'ADVISORY', isCompact: true),
                ],
              ),
              const SizedBox(height: 28),

              Text('3. AI EXPLAINABILITY FACTOR BARS', style: AppTypography.caption),
              const SizedBox(height: 10),
              const PredictionFactorBar(
                title: 'Recent 24h Rainfall (142 mm)',
                percentage: 92,
                icon: Icons.water_drop_outlined,
              ),
              const PredictionFactorBar(
                title: 'Soil Moisture Saturation (91%)',
                percentage: 86,
                icon: Icons.grain_outlined,
              ),
              const PredictionFactorBar(
                title: 'Slope Gradient (39°)',
                percentage: 79,
                icon: Icons.terrain_outlined,
              ),
              const PredictionFactorBar(
                title: '7-Day Antecedent Precipitation',
                percentage: 71,
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 28),

              Text('4. WEATHER & SENSOR STAT CARDS', style: AppTypography.caption),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: WeatherStatCard(
                      label: 'Rainfall 24h',
                      value: '142',
                      unit: 'mm',
                      icon: Icons.cloud_download_outlined,
                      isWarning: true,
                      trendText: '+18 mm in last 1h',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: WeatherStatCard(
                      label: 'Soil Moisture',
                      value: '91',
                      unit: '%',
                      icon: Icons.waves_outlined,
                      isWarning: true,
                      trendText: 'Critical saturation',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text('5. TIERED ALERT CARD', style: AppTypography.caption),
              const SizedBox(height: 10),
              AlertCard(
                title: 'High Landslide Risk Warning',
                location: 'NH-13 Lumla-Tawang Corridor',
                description:
                    'Extremely heavy precipitation exceeding 140 mm recorded in 24 hours on saturated slopes. Avoid non-essential movement along steep road cuts.',
                timeAgo: '12 mins ago',
                severity: 'CRITICAL',
                onTap: () {},
              ),
              const SizedBox(height: 28),

              Text('6. CITIZEN / OFFICER INCIDENT CARD', style: AppTypography.caption),
              const SizedBox(height: 10),
              IncidentCard(
                reportId: 'LR-2026-000123',
                category: 'Ground Crack & Debris Slide',
                severity: 'CRITICAL',
                location: 'Tawang-Lumla Road, KM 14',
                status: 'UNDER_REVIEW',
                timeAgo: '18 mins ago',
                isOfflinePending: false,
                onTap: () {},
              ),
              IncidentCard(
                reportId: 'LR-2026-000124',
                category: 'Soil Erosion',
                severity: 'MODERATE',
                location: 'Dirang Hill Pass',
                status: 'PENDING_SYNC',
                timeAgo: 'Just now',
                isOfflinePending: true,
                onTap: () {},
              ),
              const SizedBox(height: 28),

              Text('7. GIS MAP FILTER CHIPS', style: AppTypography.caption),
              const SizedBox(height: 10),
              Row(
                children: [
                  MapFilterChip(
                    label: 'Risk Zones',
                    icon: Icons.warning_amber_rounded,
                    isSelected: _filterRisk,
                    count: 14,
                    onSelected: (v) => setState(() => _filterRisk = v),
                  ),
                  MapFilterChip(
                    label: 'Blocked Roads',
                    icon: Icons.alt_route_rounded,
                    isSelected: _filterRoads,
                    count: 3,
                    onSelected: (v) => setState(() => _filterRoads = v),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text('8. EMERGENCY SOS BUTTON', style: AppTypography.caption),
              const SizedBox(height: 10),
              EmergencyButton(
                onPressed: () {},
                label: 'SOS • DISASTER RESPONSE',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
