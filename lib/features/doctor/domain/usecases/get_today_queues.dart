import '../entities/queue_entity.dart';
import '../repositories/doctor_repository.dart';

class GetTodayQueues {
  final DoctorRepository repository;
  GetTodayQueues(this.repository);

  Stream<List<QueueEntity>> call(String doctorId) {
    return repository.getTodayQueues(doctorId);
  }
}
