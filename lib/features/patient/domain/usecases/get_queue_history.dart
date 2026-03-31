import '../entities/queue_entity.dart';
import '../repositories/patient_queue_repository.dart';

class GetQueueHistory {
  final PatientQueueRepository repository;

  GetQueueHistory(this.repository);

  Future<List<QueueEntity>> call(String patientId) {
    return repository.getQueueHistory(patientId);
  }
}
