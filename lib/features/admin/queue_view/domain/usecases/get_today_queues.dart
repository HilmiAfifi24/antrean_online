import '../entities/queue_admin_entity.dart';
import '../repositories/queue_admin_repository.dart';

class GetQueuesByDate {
  final QueueAdminRepository repository;

  GetQueuesByDate(this.repository);

  Stream<List<QueueAdminEntity>> call(DateTime date) {
    return repository.getQueuesByDate(date);
  }
}
