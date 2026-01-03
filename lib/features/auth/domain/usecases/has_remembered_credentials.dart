import '../repositories/auth_repository.dart';

class HasRememberedCredentials {
  final AuthRepository repository;

  HasRememberedCredentials(this.repository);

  Future<bool> call() async {
    return await repository.hasRememberedCredentials();
  }
}
