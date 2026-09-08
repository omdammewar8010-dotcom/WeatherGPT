import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/gis_feature_entity.dart';
import '../providers/risk_map_provider.dart';
import '../widgets/map_layer_toggle_bar.dart';
import '../widgets/map_legend_widget.dart';
import '../widgets/risk_zone_bottom_sheet.dart';

class RiskMapScreen extends ConsumerStatefulWidget {
  const RiskMapScreen({super.key});

  @override
  ConsumerState<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends ConsumerState<RiskMapScreen> {
  final MapController _mapController = MapController();
  // Centered on Tawang / North Eastern Region (27.586, 91.859)
  final LatLng _initialCenter = const LatLng(27.586, 91.859);
  static const double _initialZoom = 11.5;

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(riskMapStateProvider);
    final notifier = ref.read(riskMapStateProvider.notifier);
    final features = mapState.filteredFeatures;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GIS Landslide Risk Overwatch', style: AppTypography.heading3.copyWith(fontSize: 15)),
            Text(
              '8-State NER Geospatial Sensor Matrix',
              style: AppTypography.caption.copyWith(color: AppColors.accentLight, fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.accentLight),
            tooltip: 'Center on Tawang',
            onPressed: () {
              _mapController.move(_initialCenter, 12.0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh GIS Layers',
            onPressed: () => notifier.loadGisLayers(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // FlutterMap GIS Interactive Canvas
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              minZoom: 4.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                notifier.selectFeature(null);
              },
            ),
            children: [
              // OpenStreetMap Dark/Carto Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'in.gov.ner.landslideguard',
                tileBuilder: (context, tileWidget, tile) {
                  // Apply slight Gov-Tech dark filter
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.33, 0.33, 0.33, 0, -40,
                      0.33, 0.33, 0.33, 0, -35,
                      0.33, 0.33, 0.33, 0, -30,
                      0,    0,    0,    1, 0,
                    ]),
                    child: tileWidget,
                  );
                },
              ),

              // Polygon Layer for High & Critical Risk Zones
              PolygonLayer(
                polygons: features
                    .where((f) => f.polygonPoints != null && f.polygonPoints!.isNotEmpty)
                    .map((f) {
                  final riskColor = AppColors.getRiskColor(f.riskScore);
                  final isSelected = mapState.selectedFeature?.id == f.id;

                  return Polygon(
                    points: f.polygonPoints!,
                    color: riskColor.withValues(alpha: isSelected ? 0.45 : 0.28),
                    borderColor: riskColor,
                    borderStrokeWidth: isSelected ? 3.0 : 1.8,
                  );
                }).toList(),
              ),

              // Markers Layer for Incidents, Sensors, Infrastructure, and Sector Centers
              MarkerLayer(
                markers: features.map((f) {
                  final riskColor = AppColors.getRiskColor(f.riskScore);
                  final isSelected = mapState.selectedFeature?.id == f.id;

                  return Marker(
                    point: f.position,
                    width: isSelected ? 48 : 38,
                    height: isSelected ? 48 : 38,
                    child: GestureDetector(
                      onTap: () {
                        notifier.selectFeature(f);
                        _mapController.move(f.position, _mapController.camera.zoom);
                      },
                      child: _buildMarkerIcon(f, riskColor, isSelected),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top Filter Chip Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.background.withValues(alpha: 0.85),
              child: MapLayerToggleBar(
                activeLayers: mapState.activeLayers,
                onToggle: (layer) => notifier.toggleLayer(layer),
              ),
            ),
          ),

          // Top Right Legend Overlay
          const Positioned(
            top: 60,
            right: 14,
            child: MapLegendWidget(),
          ),

          // Sector Fast Jump Bar (Tawang, Gangtok, Shillong, Aizawl)
          Positioned(
            bottom: mapState.selectedFeature != null ? 240 : 16,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildJumpButton('Tawang', const LatLng(27.586, 91.859)),
                  const SizedBox(width: 4),
                  _buildJumpButton('Gangtok', const LatLng(27.338, 88.606)),
                  const SizedBox(width: 4),
                  _buildJumpButton('Shillong', const LatLng(25.578, 91.893)),
                  const SizedBox(width: 4),
                  _buildJumpButton('Aizawl', const LatLng(23.727, 92.717)),
                ],
              ),
            ),
          ),

          // Bottom Sheet when a feature is selected
          if (mapState.selectedFeature != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RiskZoneBottomSheet(
                feature: mapState.selectedFeature!,
                onDismiss: () => notifier.selectFeature(null),
                onDetailedAnalysis: () => context.pushNamed(
                  RouteNames.riskAnalysis,
                  queryParameters: {'location_id': mapState.selectedFeature!.id},
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarkerIcon(GisFeatureEntity feature, Color color, bool isSelected) {
    IconData icon;
    switch (feature.layerType) {
      case GisLayerType.incident:
        icon = Icons.warning_rounded;
        break;
      case GisLayerType.sensor:
        icon = Icons.sensors_rounded;
        break;
      case GisLayerType.road:
        icon = Icons.traffic_rounded;
        break;
      case GisLayerType.infrastructure:
        icon = Icons.local_hospital_rounded;
        break;
      case GisLayerType.riskZone:
        icon = Icons.landscape_rounded;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.black,
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: isSelected ? 12 : 6,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: isSelected ? 24 : 18),
      ),
    );
  }

  Widget _buildJumpButton(String name, LatLng target) {
    return InkWell(
      onTap: () => _mapController.move(target, 12.0),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          name,
          style: AppTypography.caption.copyWith(
            color: AppColors.accentLight,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
