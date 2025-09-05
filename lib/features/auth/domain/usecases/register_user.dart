import 'package:antrean_online/features/auth/domain/entities/user_entity.dart';
import 'package:antrean_online/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity> call(String email, String password, String role) {
    return repository.register(email, password, role);
  }
}