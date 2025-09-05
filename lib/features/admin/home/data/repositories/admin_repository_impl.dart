import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, int>> getDashboardStats() async {
    final totalPatients = await remoteDataSource.getTotalPatients();
    final totalDoctors = await remoteDataSource.getTotalDoctors();
    final totalSchedules = await remoteDataSource.getTotalSchedules();
    final totalQueues = await remoteDataSource.getTotalQueues();

    return {
      'totalPasien': totalPatients,
      'totalDokter': totalDoctors,
      'totalJadwal': totalSchedules,
      'totalAntrean': totalQueues,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentActivities() {
    return remoteDataSource.getRecentActivities();
  }

  @override
  Future<void> logActivity({
    required String title,
    required String subtitle,
    required String type,
  }) {
    return remoteDataSource.logActivity(
      title: title,
      subtitle: subtitle,
      type: type,
    );
  }
}
