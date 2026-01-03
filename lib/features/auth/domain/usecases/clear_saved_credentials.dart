import '../repositories/auth_repository.dart';

class ClearSavedCredentials {
  final AuthRepository repository;

  ClearSavedCredentials(this.repository);

  Future<void> call() async {
    return await repository.clearCredentials();
  }
}
