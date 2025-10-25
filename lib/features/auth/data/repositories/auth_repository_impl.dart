import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<UserEntity> register(String email, String password, String role, String name) {
    return remoteDataSource.register(email, password, role, name);
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }
}
