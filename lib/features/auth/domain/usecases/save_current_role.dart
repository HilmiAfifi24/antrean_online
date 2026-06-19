import '../repositories/auth_repository.dart';

class SaveCurrentRole {
  final AuthRepository repository;

  SaveCurrentRole(this.repository);

  Future<void> call(String role) async {
    return await repository.saveCurrentRole(role);
  }
}
