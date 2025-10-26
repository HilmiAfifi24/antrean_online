import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/queue_entity.dart';

class QueueRemoteDataSource {
  final FirebaseFirestore firestore;

  QueueRemoteDataSource(this.firestore);

  // Get patient's active queue
  Future<QueueEntity?> getActiveQueue(String patientId) async {
    try {
      final querySnapshot = await firestore
          .collection('queues')
          .where('patient_id', isEqualTo: patientId)
          .where('status', whereIn: ['menunggu', 'dipanggil'])
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      return QueueEntity(
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
    } catch (e) {
      throw Exception('Failed to get active queue: $e');
    }
  }

  // Create new queue
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
  }) async {
    try {
      // Normalize date to start of day (remove time component)
      final normalizedDate = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );

      // Get current active queue count for this schedule on this specific date
      // Only count queues that are active (menunggu, dipanggil, or selesai today)
      final scheduleQueues = await firestore
          .collection('queues')
          .where('schedule_id', isEqualTo: scheduleId)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .where('status', whereIn: ['menunggu', 'dipanggil', 'selesai'])
          .get();

      final queueNumber = scheduleQueues.docs.length + 1;

      // Create new queue document
      final docRef = await firestore.collection('queues').add({
        'patient_id': patientId,
        'patient_name': patientName,
        'schedule_id': scheduleId,
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'doctor_specialization': doctorSpecialization,
        'appointment_date': Timestamp.fromDate(normalizedDate),
        'appointment_time': appointmentTime,
        'queue_number': queueNumber,
        'status': 'menunggu',
        'complaint': complaint,
        'created_at': FieldValue.serverTimestamp(),
      });

      // NOTE: Do NOT update a global 'current_patients' on the schedule here.
      // Booking counts should be calculated per (schedule_id + appointment_date).

      return QueueEntity(
        id: docRef.id,
        patientId: patientId,
        patientName: patientName,
        scheduleId: scheduleId,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialization: doctorSpecialization,
        appointmentDate: normalizedDate,
        appointmentTime: appointmentTime,
        queueNumber: queueNumber,
        status: 'menunggu',
        complaint: complaint,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to create queue: $e');
    }
  }

  // Cancel queue (mark as cancelled). Do NOT modify a global schedule counter here.
  Future<void> cancelQueue(String queueId, String scheduleId) async {
    try {
      // scheduleId is accepted for API compatibility but not used here.
      await firestore.collection('queues').doc(queueId).update({
        'status': 'dibatalkan',
        'cancelled_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel queue: $e');
    }
  }

  // Stream active queue
  Stream<QueueEntity?> watchActiveQueue(String patientId) {
    // Add defensive error handling to the stream to avoid throwing when Firestore
    // returns FAILED_PRECONDITION (missing composite index). The stream will
    // emit null on error so callers can handle absence of data gracefully.
    return firestore
        .collection('queues')
        .where('patient_id', isEqualTo: patientId)
        .where('status', whereIn: ['menunggu', 'dipanggil'])
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .handleError((error) {
      // Swallow Firestore index errors here and log for diagnostics.
      // Do not rethrow to avoid crashing the stream consumers.
      // ignore: avoid_print
      print('[QueueRemoteDataSource] watchActiveQueue stream error: $error');
    }).map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();

      return QueueEntity(
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
    });
  }
}
