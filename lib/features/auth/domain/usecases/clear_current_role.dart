import '../repositories/auth_repository.dart';

class ClearCurrentRole {
  final AuthRepository repository;

  ClearCurrentRole(this.repository);

  Future<void> call() async {
    return await repository.clearCurrentRole();
  }
}
