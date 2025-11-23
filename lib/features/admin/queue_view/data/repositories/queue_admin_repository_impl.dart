import '../../domain/entities/queue_admin_entity.dart';
import '../../domain/repositories/queue_admin_repository.dart';
import '../datasources/queue_admin_remote_datasource.dart';

class QueueAdminRepositoryImpl implements QueueAdminRepository {
  final QueueAdminRemoteDataSource dataSource;

  QueueAdminRepositoryImpl(this.dataSource);

  @override
  Stream<List<QueueAdminEntity>> getQueuesByDate(DateTime date) {
    return dataSource.getQueuesByDate(date);
  }

  @override
  Future<List<QueueAdminEntity>> getQueuesByDateOnce(DateTime date) {
    return dataSource.getQueuesByDateOnce(date);
  }
}
