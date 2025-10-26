import '../entities/schedule_entity.dart';
import '../repositories/patient_schedule_repository.dart';

class GetSchedulesByDay {
  final PatientScheduleRepository repository;

  GetSchedulesByDay(this.repository);

  Future<List<ScheduleEntity>> call(String day) async {
    return await repository.getSchedulesByDay(day);
  }
}
