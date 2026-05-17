import '../entities/schedule_entity.dart';
import '../repositories/patient_queue_repository.dart';

class GetAvailableRescheduleDates {
  final PatientQueueRepository repository;

  GetAvailableRescheduleDates(this.repository);

  Future<List<ScheduleEntity>> call(String queueId) {
    return repository.getAvailableRescheduleDates(queueId);
  }
}
