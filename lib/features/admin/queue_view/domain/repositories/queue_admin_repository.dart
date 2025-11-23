import '../entities/queue_admin_entity.dart';

abstract class QueueAdminRepository {
  Stream<List<QueueAdminEntity>> getQueuesByDate(DateTime date);
  Future<List<QueueAdminEntity>> getQueuesByDateOnce(DateTime date);
}
