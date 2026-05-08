import '../entities/queue_entity.dart';
import '../repositories/doctor_repository.dart';

class GetCompletedQueues {
  final DoctorRepository repository;

  GetCompletedQueues(this.repository);

  Stream<List<QueueEntity>> call(String doctorId, DateTime date) {
    return repository.getCompletedQueues(doctorId, date);
  }
}
