import '../../domain/entities/queue_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/patient_queue_repository.dart';
import '../datasources/queue_remote_datasource.dart';

class PatientQueueRepositoryImpl implements PatientQueueRepository {
  final QueueRemoteDataSource dataSource;

  PatientQueueRepositoryImpl(this.dataSource);

  @override
  Future<List<QueueEntity>> getActiveQueues(String patientId) {
    return dataSource.getActiveQueues(patientId);
  }

  @override
  Future<bool> validateMultipleBooking({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
  }) {
    return dataSource.validateMultipleBooking(
      patientId: patientId,
      doctorId: doctorId,
      appointmentDate: appointmentDate,
    );
  }

  @override
  Future<QueueEntity> createQueue({
    required String patientId,
    required String patientName,
    String? patientPhone,
    DateTime? birthDate,
    String? gender,
    required String scheduleId,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialization,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String complaint,
  }) {
    return dataSource.createQueue(
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      birthDate: birthDate,
      gender: gender,
      scheduleId: scheduleId,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      complaint: complaint,
    );
  }

  @override
  Future<void> cancelQueue(String queueId, String scheduleId) {
    return dataSource.cancelQueue(queueId, scheduleId);
  }

  @override
  Future<void> validateRescheduleEligibility(String queueId) {
    return dataSource.validateRescheduleEligibility(queueId);
  }

  @override
  Future<List<ScheduleEntity>> getAvailableRescheduleDates(String queueId) {
    return dataSource.getAvailableRescheduleDates(queueId);
  }

  @override
  Future<QueueEntity> rescheduleQueue({
    required String queueId,
    required String newScheduleId,
    required DateTime newDate,
  }) {
    return dataSource.rescheduleQueue(
      queueId: queueId,
      newScheduleId: newScheduleId,
      newDate: newDate,
    );
  }

  @override
  Stream<List<QueueEntity>> watchActiveQueues(String patientId) {
    return dataSource.watchActiveQueues(patientId);
  }

  @override
  Stream<int?> watchCurrentClinicQueueNumber({
    required String scheduleId,
    required DateTime appointmentDate,
  }) {
    return dataSource.watchCurrentClinicQueueNumber(
      scheduleId: scheduleId,
      appointmentDate: appointmentDate,
    );
  }

  @override
  Stream<int> watchWaitingCountBeforeQueue({
    required String scheduleId,
    required DateTime appointmentDate,
    required int queueNumber,
  }) {
    return dataSource.watchWaitingCountBeforeQueue(
      scheduleId: scheduleId,
      appointmentDate: appointmentDate,
      queueNumber: queueNumber,
    );
  }

  @override
  Future<List<QueueEntity>> getQueueHistory(String patientId) {
    return dataSource.getQueueHistory(patientId);
  }
}
