import '../entities/schedule_entity.dart';
import '../entities/schedule_date_availability.dart';

abstract class PatientScheduleRepository {
  Future<List<ScheduleEntity>> getAllActiveSchedules();
  Future<List<ScheduleEntity>> getSchedulesByDay(String day);
  Future<List<ScheduleEntity>> searchSchedules(String query);
  Stream<List<ScheduleEntity>> getSchedulesByDayStream(String day);

  Stream<List<ScheduleDateAvailability>> getScheduleDatesStream(
    String scheduleId,
    List<DateTime> upcomingDates,
    int maxPatients,
  );
}
