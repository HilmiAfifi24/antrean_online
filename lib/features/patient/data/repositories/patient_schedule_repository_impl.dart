import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/schedule_date_availability.dart';
import '../../domain/repositories/patient_schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

class PatientScheduleRepositoryImpl implements PatientScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  PatientScheduleRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ScheduleEntity>> getAllActiveSchedules() async {
    return await remoteDataSource.getAllActiveSchedules();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByDay(String day) async {
    return await remoteDataSource.getSchedulesByDay(day);
  }

  @override
  Future<List<ScheduleEntity>> searchSchedules(String query) async {
    return await remoteDataSource.searchSchedules(query);
  }

  @override
  Stream<List<ScheduleEntity>> getSchedulesByDayStream(String day) {
    return remoteDataSource.getSchedulesByDayStream(day);
  }

  @override
  Stream<List<ScheduleDateAvailability>> getScheduleDatesStream(
    String scheduleId,
    List<DateTime> upcomingDates,
    int maxPatients,
  ) {
    return remoteDataSource.getScheduleDatesStream(
      scheduleId,
      upcomingDates,
      maxPatients,
    );
  }
}
