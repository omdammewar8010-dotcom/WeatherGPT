import 'package:ner_landslideguard/features/roads_overwatch/domain/entities/road_corridor_entity.dart';

abstract class RoadsRepository {
  Future<List<RoadCorridorEntity>> getRoadCorridors();
  Future<List<HistoricalLandslideEventEntity>> getHistoricalLandslides({int? year, String? state});
  Future<RoadCorridorEntity> reportRoadBlockage(RoadCorridorEntity report);
}
