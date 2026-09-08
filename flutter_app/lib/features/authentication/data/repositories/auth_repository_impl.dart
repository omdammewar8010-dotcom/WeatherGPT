import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> loginWithCredentials({
    required String identifier,
    required String password,
  }) async {
    final user = await remoteDataSource.loginWithCredentials(identifier, password);
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<UserEntity> registerUser({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String state,
    required String district,
    String? village,
    required UserRole role,
  }) async {
    final payload = {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'state': state,
      'district': district,
      'village': village,
      'role': role.id,
    };
    final user = await remoteDataSource.register(payload);
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<UserEntity> switchDemoProfile(UserRole role) async {
    late UserModel demoUser;
    switch (role) {
      case UserRole.citizen:
        demoUser = UserModel.demoCitizen;
        break;
      case UserRole.fieldOfficer:
        demoUser = UserModel.demoOfficer;
        break;
      case UserRole.authorityAdmin:
        demoUser = UserModel.demoAdmin;
        break;
    }
    await localDataSource.cacheUser(demoUser);
    return demoUser;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await localDataSource.getCachedUser();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAuthCache();
  }
}
