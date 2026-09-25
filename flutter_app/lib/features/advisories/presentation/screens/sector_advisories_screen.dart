import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SectorAdvisoriesScreen extends StatefulWidget {
  const SectorAdvisoriesScreen({super.key});

  @override
  State<SectorAdvisoriesScreen> createState() => _SectorAdvisoriesScreenState();
}

class _SectorAdvisoriesScreenState extends State<SectorAdvisoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IMD Sector Intelligence Advisories', style: AppTypography.heading3.copyWith(fontSize: 16)),
            Text(
              'Targeted Decision Support (MoES / IMD SIH26068)',
              style: AppTypography.caption.copyWith(color: AppColors.accentLight, fontSize: 10),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accentLight,
          labelColor: AppColors.accentLight,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.agriculture_rounded, size: 18), text: 'Agromet (Farmers)'),
            Tab(icon: Icon(Icons.flight_takeoff_rounded, size: 18), text: 'Aviation & Drones'),
            Tab(icon: Icon(Icons.sailing_rounded, size: 18), text: 'Marine & Coastal'),
            Tab(icon: Icon(Icons.location_city_rounded, size: 18), text: 'Smart City & Urban'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAgrometTab(),
          _buildAviationTab(),
          _buildMarineTab(),
          _buildSmartCityTab(),
        ],
      ),
    );
  }

  Widget _buildAgrometTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroBanner(
          title: 'Monsoon Agromet Advisory Bulletin',
          subtitle: 'Valid for Sali Paddy, Maize & Tea Plantations',
          severity: 'ORANGE ALERT',
          color: AppColors.riskHigh,
          icon: Icons.grass_rounded,
        ),
        const SizedBox(height: 16),
        _buildAdvisoryCard(
          title: '🌾 Sali Paddy (Transplanting & Nursery Stage)',
          status: 'Drain Standing Water',
          points: [
            'Continuous precipitation (> 68mm) expected. Keep drainage outlets open in nursery beds to prevent submergence.',
            'Suspend urea top-dressing and chemical weedicide application until dry spell returns.',
            'Watch for bacterial leaf blight symptoms in high humidity conditions (> 85% RH).',
          ],
        ),
        const SizedBox(height: 12),
        _buildAdvisoryCard(
          title: '🍵 Tea Gardens & Hill Slopes',
          status: 'Fungal Blight Precaution',
          points: [
            'Red spider mite risk is mitigated by rain, but black rot fungal infestation risk is elevated.',
            'Ensure drainage channels in valley tea sections are de-silted to prevent waterlogging.',
            'Postpone foliar micronutrient spraying for the next 48 hours.',
          ],
        ),
        const SizedBox(height: 12),
        _buildAdvisoryCard(
          title: '🌽 Maize & Seasonal Vegetables',
          status: 'Harvest Advisory',
          points: [
            'Harvest mature cobs immediately and store in elevated dry storage bins.',
            'Provide staking support to tomato and chili plants against squally wind gusts (up to 55 km/h).',
          ],
        ),
      ],
    );
  }

  Widget _buildAviationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroBanner(
          title: 'Aviation Aerodrome Weather Briefing',
          subtitle: 'Guwahati (VEGT) & Shillong (VEBI) FIR',
          severity: 'MODERATE TURBULENCE',
          color: AppColors.riskModerate,
          icon: Icons.airplanemode_active_rounded,
        ),
        const SizedBox(height: 16),
        _buildAdvisoryCard(
          title: '✈️ Aerodrome Runway & Surface Wind',
          status: 'Runway Wet — Braking Action Medium',
          points: [
            'Runway 02/20: Surface wind 220° / 22 kts, gusting to 34 kts.',
            'Crosswind component on runway 02 is 18 kts; within narrow-body limits but wind shear reported below 1000ft.',
            'Visual Range (RVR): 1800m in moderate convective showers; cloud ceiling 800 ft AGL.',
          ],
        ),
        const SizedBox(height: 12),
        _buildAdvisoryCard(
          title: '🚁 Drone / UAV Operations Directive',
          status: 'Operations Prohibited in Convective Zones',
          points: [
            'All commercial drone flights suspended below 400 ft due to rapid downdraft gusts (> 45 km/h).',
            'Severe radar core reflectivity (> 52 dBZ) detected within 15 km aerodrome radius.',
          ],
        ),
      ],
    );
  }

  Widget _buildMarineTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroBanner(
          title: 'Marine Weather & Fishermen Warning',
          subtitle: 'Bay of Bengal & Coastal Riverine Waters',
          severity: 'ROUGH SEA WARNING',
          color: AppColors.riskCritical,
          icon: Icons.waves_rounded,
        ),
        const SizedBox(height: 16),
        _buildAdvisoryCard(
          title: '⚓ Port Warning Signals & Sea State',
          status: 'Local Cautionary Signal No. III Hoisted',
          points: [
            'Squally weather with wind speeds reaching 45-55 km/h gusting to 65 km/h prevailing over deep sea sectors.',
            'Wave heights predicted between 3.5m and 4.8m. Sea condition will be rough to very rough.',
            'Total ban on motorized and non-motorized fishing boats venturing into deep sea for 72 hours.',
          ],
        ),
        const SizedBox(height: 12),
        _buildAdvisoryCard(
          title: '🚢 Inland Riverine Transport (Brahmaputra/Hooghly)',
          status: 'Ferry Operations Suspended',
          points: [
            'Inland water transport ferry services between North and South Guwahati suspended due to strong river turbulence and zero visibility.',
          ],
        ),
      ],
    );
  }

  Widget _buildSmartCityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroBanner(
          title: 'Smart City Urban Resilience Overwatch',
          subtitle: 'Storm Drainage & Heat Stress Analytics',
          severity: 'FLASH INUNDATION WATCH',
          color: AppColors.riskHigh,
          icon: Icons.apartment_rounded,
        ),
        const SizedBox(height: 16),
        _buildAdvisoryCard(
          title: '🌊 Urban Drainage & Waterlogging Hotspots',
          status: 'Critical Surcharge on Arterial Drains',
          points: [
            'Inundation probability > 78% in low-lying underpasses (Rukminigaon, Anil Nagar, Zoo Road).',
            'Pumping stations operating at 85% capacity; municipal standby crews deployed.',
            'Citizens advised to plan alternative traffic corridors and avoid basements in flood-prone wards.',
          ],
        ),
        const SizedBox(height: 12),
        _buildAdvisoryCard(
          title: '🌡️ Urban Heat Island & Air Quality Index',
          status: 'AQI: 55 (Satisfactory)',
          points: [
            'Precipitation washout has reduced PM2.5 concentrations to 28 µg/m³.',
            'Thermal comfort index is within safe limits (Wet Bulb Globe Temp: 26.2°C).',
          ],
        ),
      ],
    );
  }

  Widget _buildHeroBanner({
    required String title,
    required String subtitle,
    required String severity,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    severity,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(title, style: AppTypography.heading3.copyWith(fontSize: 15)),
                Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCard({
    required String title,
    required String status,
    required List<String> points,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.accentLight.withOpacity(0.3)),
                ),
                child: Text(status, style: const TextStyle(fontSize: 10, color: AppColors.accentLight, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 16),
          ...points.map(
            (pt) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.accentLight, fontSize: 14)),
                  Expanded(
                    child: Text(pt, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
