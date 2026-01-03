import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<UserEntity> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<UserEntity> register(String email, String password, String role, String name, String phone) {
    return remoteDataSource.register(email, password, role, name, phone);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    // Clear saved credentials on logout
    await localDataSource.clearCredentials();
  }

  @override
  Future<void> resetPassword(String email) {
    return remoteDataSource.resetPassword(email);
  }

  @override
  Future<void> saveCredentials(String email, String password) {
    return localDataSource.saveCredentials(email, password);
  }

  @override
  Future<Map<String, String>?> getSavedCredentials() {
    return localDataSource.getSavedCredentials();
  }

  @override
  Future<void> clearCredentials() {
    return localDataSource.clearCredentials();
  }

  @override
  Future<bool> hasRememberedCredentials() {
    return localDataSource.hasRememberedCredentials();
  }
}
