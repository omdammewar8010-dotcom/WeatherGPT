import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // User Role
  Future<bool> setUserRole(String role) => _prefs.setString(AppConstants.keyUserRole, role);
  String getUserRole() => _prefs.getString(AppConstants.keyUserRole) ?? AppConstants.roleCitizen;

  // Auth Token
  Future<bool> setAuthToken(String token) => _prefs.setString(AppConstants.keyAuthToken, token);
  String? getAuthToken() => _prefs.getString(AppConstants.keyAuthToken);

  // Demo Mode
  Future<bool> setDemoMode(bool isDemo) => _prefs.setBool(AppConstants.keyDemoMode, isDemo);
  bool isDemoMode() => _prefs.getBool(AppConstants.keyDemoMode) ?? true;

  // Offline Report Queue
  Future<bool> saveOfflineReports(List<Map<String, dynamic>> reports) {
    return _prefs.setString(AppConstants.keyOfflineQueue, jsonEncode(reports));
  }

  List<Map<String, dynamic>> getOfflineReports() {
    final raw = _prefs.getString(AppConstants.keyOfflineQueue);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> clearSession() async {
    await _prefs.remove(AppConstants.keyAuthToken);
    await _prefs.remove(AppConstants.keyUserData);
    return true;
  }
}
