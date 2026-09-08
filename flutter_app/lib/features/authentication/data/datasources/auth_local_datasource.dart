import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearAuthCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
    await sharedPreferences.setString(AppConstants.keyUserRole, user.role.id);
    if (user.token != null) {
      await sharedPreferences.setString(AppConstants.keyAuthToken, user.token!);
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final raw = sharedPreferences.getString(AppConstants.keyUserData);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAuthCache() async {
    await sharedPreferences.remove(AppConstants.keyUserData);
    await sharedPreferences.remove(AppConstants.keyAuthToken);
    await sharedPreferences.remove(AppConstants.keyUserRole);
  }
}
