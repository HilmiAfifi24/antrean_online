import '../repositories/auth_repository.dart';

class GetSavedCredentials {
  final AuthRepository repository;

  GetSavedCredentials(this.repository);

  Future<Map<String, String>?> call() async {
    return await repository.getSavedCredentials();
  }
}
