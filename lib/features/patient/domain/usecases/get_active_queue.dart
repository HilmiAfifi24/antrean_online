import '../entities/queue_entity.dart';
import '../repositories/patient_queue_repository.dart';

class GetActiveQueue {
  final PatientQueueRepository repository;

  GetActiveQueue(this.repository);

  Future<QueueEntity?> call(String patientId) {
    return repository.getActiveQueue(patientId);
  }
}
