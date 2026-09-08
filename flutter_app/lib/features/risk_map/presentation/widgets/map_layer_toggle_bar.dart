import 'package:flutter/material.dart';
import '../../../../core/widgets/map_filter_chip.dart';
import '../../domain/entities/gis_feature_entity.dart';

class MapLayerToggleBar extends StatelessWidget {
  final Set<GisLayerType> activeLayers;
  final ValueChanged<GisLayerType> onToggle;

  const MapLayerToggleBar({
    super.key,
    required this.activeLayers,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          MapFilterChip(
            label: 'Risk Zones',
            icon: Icons.shield_outlined,
            isSelected: activeLayers.contains(GisLayerType.riskZone),
            onSelected: (_) => onToggle(GisLayerType.riskZone),
          ),
          MapFilterChip(
            label: 'Landslides',
            icon: Icons.landslide_outlined,
            isSelected: activeLayers.contains(GisLayerType.incident),
            onSelected: (_) => onToggle(GisLayerType.incident),
          ),
          MapFilterChip(
            label: 'Roads (NH/SH)',
            icon: Icons.alt_route_rounded,
            isSelected: activeLayers.contains(GisLayerType.road),
            onSelected: (_) => onToggle(GisLayerType.road),
          ),
          MapFilterChip(
            label: 'IoT Sensors',
            icon: Icons.sensors_rounded,
            isSelected: activeLayers.contains(GisLayerType.sensor),
            onSelected: (_) => onToggle(GisLayerType.sensor),
          ),
          MapFilterChip(
            label: 'Critical Assets',
            icon: Icons.local_hospital_outlined,
            isSelected: activeLayers.contains(GisLayerType.infrastructure),
            onSelected: (_) => onToggle(GisLayerType.infrastructure),
          ),
        ],
      ),
    );
  }
}
