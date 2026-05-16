import '../entities/queue_entity.dart';
import '../repositories/patient_queue_repository.dart';

class CreateQueueParams {
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final DateTime? birthDate;
  final String? gender;
  final String scheduleId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String complaint;

  CreateQueueParams({
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    this.birthDate,
    this.gender,
    required this.scheduleId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.complaint,
  });
}

class CreateQueue {
  final PatientQueueRepository repository;

  CreateQueue(this.repository);

  Future<QueueEntity> call(CreateQueueParams params) {
    return repository.createQueue(
      patientId: params.patientId,
      patientName: params.patientName,
      patientPhone: params.patientPhone,
      birthDate: params.birthDate,
      gender: params.gender,
      scheduleId: params.scheduleId,
      doctorId: params.doctorId,
      doctorName: params.doctorName,
      doctorSpecialization: params.doctorSpecialization,
      appointmentDate: params.appointmentDate,
      appointmentTime: params.appointmentTime,
      complaint: params.complaint,
    );
  }
}
