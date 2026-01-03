import '../entities/schedule_entity.dart';

abstract class PatientScheduleRepository {
  Future<List<ScheduleEntity>> getAllActiveSchedules();
  Future<List<ScheduleEntity>> getSchedulesByDay(String day);
  Future<List<ScheduleEntity>> searchSchedules(String query);
  Stream<List<ScheduleEntity>> getSchedulesByDayStream(String day);
}
