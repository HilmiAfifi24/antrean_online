import '../../domain/entities/queue_entity.dart';
import '../entities/schedule_entity.dart';

abstract class PatientQueueRepository {
  Future<List<QueueEntity>> getActiveQueues(String patientId);

  Future<bool> validateMultipleBooking({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
  });

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
  });

  Future<void> cancelQueue(String queueId, String scheduleId);

  Future<void> validateRescheduleEligibility(String queueId);

  Future<List<ScheduleEntity>> getAvailableRescheduleDates(String queueId);

  Future<QueueEntity> rescheduleQueue({
    required String queueId,
    required String newScheduleId,
    required DateTime newDate,
  });

  Stream<List<QueueEntity>> watchActiveQueues(String patientId);

  Stream<int?> watchCurrentClinicQueueNumber({
    required String scheduleId,
    required DateTime appointmentDate,
  });

  Stream<int> watchWaitingCountBeforeQueue({
    required String scheduleId,
    required DateTime appointmentDate,
    required int queueNumber,
  });

  Future<List<QueueEntity>> getQueueHistory(String patientId);
}
