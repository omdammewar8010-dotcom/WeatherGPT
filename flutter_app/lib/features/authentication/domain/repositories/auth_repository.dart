import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> loginWithCredentials({
    required String identifier,
    required String password,
  });

  Future<UserEntity> registerUser({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String state,
    required String district,
    String? village,
    required UserRole role,
  });

  Future<UserEntity> switchDemoProfile(UserRole role);

  Future<UserEntity?> getCurrentUser();

  Future<void> logout();
}
