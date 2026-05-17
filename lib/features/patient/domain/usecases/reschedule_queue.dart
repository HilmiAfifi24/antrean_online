import '../entities/queue_entity.dart';
import '../repositories/patient_queue_repository.dart';

class RescheduleQueueParams {
  final String queueId;
  final String newScheduleId;
  final DateTime newDate;

  const RescheduleQueueParams({
    required this.queueId,
    required this.newScheduleId,
    required this.newDate,
  });
}

class RescheduleQueue {
  final PatientQueueRepository repository;

  RescheduleQueue(this.repository);

  Future<QueueEntity> call(RescheduleQueueParams params) {
    return repository.rescheduleQueue(
      queueId: params.queueId,
      newScheduleId: params.newScheduleId,
      newDate: params.newDate,
    );
  }
}
