import '../entities/schedule_date_availability.dart';
import '../repositories/patient_schedule_repository.dart';

class GetScheduleDatesStream {
  final PatientScheduleRepository repository;

  GetScheduleDatesStream(this.repository);

  Stream<List<ScheduleDateAvailability>> call(
    String scheduleId,
    List<DateTime> upcomingDates,
    int maxPatients,
  ) {
    return repository.getScheduleDatesStream(
      scheduleId,
      upcomingDates,
      maxPatients,
    );
  }
}
