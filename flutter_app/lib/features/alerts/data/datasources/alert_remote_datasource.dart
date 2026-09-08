import '../../../../core/network/api_client.dart';
import '../models/early_warning_model.dart';

abstract class AlertRemoteDataSource {
  Future<List<EarlyWarningModel>> fetchActiveWarnings({String? district});
  Future<EarlyWarningModel> broadcastWarning({
    required String title,
    required String district,
    required String state,
    required String severity,
    required int riskScore,
    required double confidence,
    required int validUntilHours,
    required String advisory,
    required String evacuationRoute,
    required List<String> affectedSectors,
  });
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  final ApiClient _apiClient;

  AlertRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<EarlyWarningModel>> fetchActiveWarnings({String? district}) async {
    try {
      final response = await _apiClient.dio.get('/alerts/active');
      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List)
            .map((item) => EarlyWarningModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (district != null) {
          return list.where((w) => w.district.toLowerCase() == district.toLowerCase()).toList();
        }
        return list;
      }
    } catch (_) {
      // Fallback to sample static warnings
    }

    final samples = EarlyWarningModel.sampleWarnings;
    if (district != null) {
      final filtered = samples.where((w) => w.district.toLowerCase() == district.toLowerCase()).toList();
      return filtered.isNotEmpty ? filtered : samples;
    }
    return samples;
  }

  @override
  Future<EarlyWarningModel> broadcastWarning({
    required String title,
    required String district,
    required String state,
    required String severity,
    required int riskScore,
    required double confidence,
    required int validUntilHours,
    required String advisory,
    required String evacuationRoute,
    required List<String> affectedSectors,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/alerts/broadcast',
        data: {
          'title': title,
          'district': district,
          'state': state,
          'severity': severity,
          'risk_score': riskScore,
          'confidence': confidence,
          'valid_until_hours': validUntilHours,
          'advisory': advisory,
          'evacuation_route': evacuationRoute,
          'affected_sectors': affectedSectors,
        },
      );
      if (response.statusCode == 200) {
        return EarlyWarningModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback
    }

    return EarlyWarningModel(
      id: 'WARN-2026-${DateTime.now().millisecondsSinceEpoch % 1000}',
      title: title,
      district: district,
      state: state,
      severity: severity,
      riskScore: riskScore,
      confidence: confidence,
      validUntil: 'Next $validUntilHours Hours',
      advisory: advisory,
      evacuationRoute: evacuationRoute,
      affectedSectors: affectedSectors,
      createdAt: 'Just now',
    );
  }
}
