import '../repositories/admin_repository.dart';

class GetDashboardStats {
  final AdminRepository repository;

  GetDashboardStats(this.repository);

  Future<Map<String, int>> call() {
    return repository.getDashboardStats();
  }
}