import '../../domain/entities/queue_entity.dart';

abstract class PatientQueueRepository {
  Future<QueueEntity?> getActiveQueue(String patientId);
  
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
  });
  
  Future<void> cancelQueue(String queueId, String scheduleId);
  
  Stream<QueueEntity?> watchActiveQueue(String patientId);
}
