import '../repositories/auth_repository.dart';

class SaveCredentials {
  final AuthRepository repository;

  SaveCredentials(this.repository);

  Future<void> call(String email, String password) async {
    return await repository.saveCredentials(email, password);
  }
}
