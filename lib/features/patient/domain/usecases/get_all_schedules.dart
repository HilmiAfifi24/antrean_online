import '../entities/schedule_entity.dart';
import '../repositories/patient_schedule_repository.dart';

class GetAllSchedules {
  final PatientScheduleRepository repository;

  GetAllSchedules(this.repository);

  Future<List<ScheduleEntity>> call() async {
    return await repository.getAllActiveSchedules();
  }
}
