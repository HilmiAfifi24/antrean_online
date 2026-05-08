import '../entities/schedule_entity.dart';
import '../repositories/patient_schedule_repository.dart';

class GetAllPatientSchedules {
  final PatientScheduleRepository repository;

  GetAllPatientSchedules(this.repository);

  Future<List<ScheduleEntity>> call() async {
    return await repository.getAllActiveSchedules();
  }
}
