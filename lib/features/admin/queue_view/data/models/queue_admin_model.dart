import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/queue_admin_entity.dart';

class QueueAdminModel extends QueueAdminEntity {
  const QueueAdminModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.scheduleId,
    required super.doctorId,
    required super.doctorName,
    required super.doctorSpecialization,
    required super.appointmentDate,
    required super.appointmentTime,
    required super.queueNumber,
    required super.status,
    required super.complaint,
    required super.createdAt,
  });

  factory QueueAdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return QueueAdminModel(
      id: doc.id,
      patientId: data['patient_id'] ?? '',
      patientName: data['patient_name'] ?? '',
      scheduleId: data['schedule_id'] ?? '',
      doctorId: data['doctor_id'] ?? '',
      doctorName: data['doctor_name'] ?? '',
      doctorSpecialization: data['doctor_specialization'] ?? '',
      appointmentDate: data['appointment_date'] != null
          ? (data['appointment_date'] as Timestamp).toDate()
          : DateTime.now(),
      appointmentTime: data['appointment_time'] ?? '',
      queueNumber: data['queue_number'] ?? 0,
      status: data['status'] ?? 'menunggu',
      complaint: data['complaint'] ?? '',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'patient_name': patientName,
      'schedule_id': scheduleId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_specialization': doctorSpecialization,
      'appointment_date': Timestamp.fromDate(appointmentDate),
      'appointment_time': appointmentTime,
      'queue_number': queueNumber,
      'status': status,
      'complaint': complaint,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
