import '../repositories/auth_repository.dart';

class GetCurrentRole {
  final AuthRepository repository;

  GetCurrentRole(this.repository);

  Future<String?> call() async {
    return await repository.getCurrentRole();
  }
}
