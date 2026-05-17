import '../repositories/patient_queue_repository.dart';

class ValidateRescheduleEligibility {
  final PatientQueueRepository repository;

  ValidateRescheduleEligibility(this.repository);

  Future<void> call(String queueId) {
    return repository.validateRescheduleEligibility(queueId);
  }
}
