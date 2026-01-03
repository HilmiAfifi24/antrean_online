import '../entities/schedule_entity.dart';
import '../repositories/patient_schedule_repository.dart';

class GetSchedulesByDayStream {
  final PatientScheduleRepository repository;

  GetSchedulesByDayStream(this.repository);

  Stream<List<ScheduleEntity>> call(String day) {
    if (day.isEmpty) {
      throw Exception('Hari tidak boleh kosong');
    }
    return repository.getSchedulesByDayStream(day);
  }
}
