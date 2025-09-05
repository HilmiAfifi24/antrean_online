import '../repositories/admin_repository.dart';

class GetRecentActivities {
  final AdminRepository repository;

  GetRecentActivities(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getRecentActivities();
  }
}