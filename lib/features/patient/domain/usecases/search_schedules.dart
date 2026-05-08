import '../entities/schedule_entity.dart';
import '../repositories/patient_schedule_repository.dart';

class SearchPatientSchedules {
  final PatientScheduleRepository repository;

  SearchPatientSchedules(this.repository);

  Future<List<ScheduleEntity>> call(String query) async {
    return await repository.searchSchedules(query);
  }
}
