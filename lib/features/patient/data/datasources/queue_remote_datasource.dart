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

      // Check for expiration
      final appointmentDate = data['appointment_date'] != null
          ? (data['appointment_date'] as Timestamp).toDate()
          : DateTime.now();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final appointmentDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );

      if (appointmentDay.isBefore(today)) {
        // Auto-cancel expired queue
        await cancelQueue(doc.id, data['schedule_id'] ?? '');
        return null;
      }

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
          .where(
            'appointment_date',
            isEqualTo: Timestamp.fromDate(normalizedDate),
          )
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
    return firestore
        .collection('queues')
        .where('patient_id', isEqualTo: patientId)
        .where('status', whereIn: ['menunggu', 'dipanggil'])
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .handleError((error) {
          // print(
          //   '[QueueRemoteDataSource] watchActiveQueue stream error: $error',
          // );
        })
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          final doc = snapshot.docs.first;
          final data = doc.data();

          // Check for expiration
          final appointmentDate = data['appointment_date'] != null
              ? (data['appointment_date'] as Timestamp).toDate()
              : DateTime.now();

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final appointmentDay = DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
          );

          if (appointmentDay.isBefore(today)) {
            // Auto-cancel expired queue
            await cancelQueue(doc.id, data['schedule_id'] ?? '');
            return null;
          }

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

  // Stream current queue number in clinic.
  // Priority: currently called (dipanggil) -> latest completed (selesai) -> null.
  Stream<int?> watchCurrentClinicQueueNumber({
    required String scheduleId,
    required DateTime appointmentDate,
  }) {
    final normalizedDate = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
    );

    return firestore
        .collection('queues')
        .where('schedule_id', isEqualTo: scheduleId)
        .where('appointment_date', isEqualTo: Timestamp.fromDate(normalizedDate))
        .where('status', whereIn: ['dipanggil', 'selesai'])
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          final docs = snapshot.docs.map((d) => d.data()).toList();

          final calledDocs = docs.where((d) => d['status'] == 'dipanggil').toList();
          if (calledDocs.isNotEmpty) {
            calledDocs.sort((a, b) {
              final aQueue = (a['queue_number'] as num?)?.toInt() ?? 999999;
              final bQueue = (b['queue_number'] as num?)?.toInt() ?? 999999;
              return aQueue.compareTo(bQueue);
            });
            return (calledDocs.first['queue_number'] as num?)?.toInt();
          }

          final completedDocs = docs.where((d) => d['status'] == 'selesai').toList();
          if (completedDocs.isEmpty) {
            return null;
          }

          completedDocs.sort((a, b) {
            final aCompleted = a['completed_at'];
            final bCompleted = b['completed_at'];
            final aMillis = aCompleted is Timestamp
                ? aCompleted.millisecondsSinceEpoch
                : 0;
            final bMillis = bCompleted is Timestamp
                ? bCompleted.millisecondsSinceEpoch
                : 0;

            if (aMillis == bMillis) {
              final aQueue = (a['queue_number'] as num?)?.toInt() ?? 0;
              final bQueue = (b['queue_number'] as num?)?.toInt() ?? 0;
              return bQueue.compareTo(aQueue);
            }

            return bMillis.compareTo(aMillis);
          });

          return (completedDocs.first['queue_number'] as num?)?.toInt();
        });
  }

  Stream<int> watchWaitingCountBeforeQueue({
    required String scheduleId,
    required DateTime appointmentDate,
    required int queueNumber,
  }) {
    final normalizedDate = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
    );

    return firestore
        .collection('queues')
        .where('schedule_id', isEqualTo: scheduleId)
        .where('appointment_date', isEqualTo: Timestamp.fromDate(normalizedDate))
        .where('status', whereIn: ['menunggu', 'dipanggil'])
        .where('queue_number', isLessThan: queueNumber)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get queue history (selesai and dibatalkan)
  Future<List<QueueEntity>> getQueueHistory(String patientId) async {
    try {
      final querySnapshot = await firestore
          .collection('queues')
          .where('patient_id', isEqualTo: patientId)
          .where('status', whereIn: ['selesai', 'dibatalkan'])
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
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
          status: data['status'] ?? 'selesai',
          complaint: data['complaint'] ?? '',
          createdAt: data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get queue history: $e');
    }
  }
}
