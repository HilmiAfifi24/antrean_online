import '../repositories/auth_repository.dart';

class GetCurrentRoleFromServer {
  final AuthRepository repository;

  GetCurrentRoleFromServer(this.repository);

  Future<String?> call() async {
    return await repository.getCurrentRoleFromServer();
  }
}
