import '../../domain/entities/queue_entity.dart';
import '../../domain/repositories/patient_queue_repository.dart';
import '../datasources/queue_remote_datasource.dart';

class PatientQueueRepositoryImpl implements PatientQueueRepository {
  final QueueRemoteDataSource dataSource;

  PatientQueueRepositoryImpl(this.dataSource);

  @override
  Future<QueueEntity?> getActiveQueue(String patientId) {
    return dataSource.getActiveQueue(patientId);
  }

  @override
  Future<QueueEntity> createQueue({
    required String patientId,
    required String patientName,
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
  Stream<QueueEntity?> watchActiveQueue(String patientId) {
    return dataSource.watchActiveQueue(patientId);
  }
}
