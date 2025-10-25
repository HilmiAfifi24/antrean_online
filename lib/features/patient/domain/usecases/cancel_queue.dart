import '../repositories/patient_queue_repository.dart';

class CancelQueueParams {
  final String queueId;
  final String scheduleId;

  CancelQueueParams({
    required this.queueId,
    required this.scheduleId,
  });
}

class CancelQueue {
  final PatientQueueRepository repository;

  CancelQueue(this.repository);

  Future<void> call(CancelQueueParams params) {
    return repository.cancelQueue(params.queueId, params.scheduleId);
  }
}
