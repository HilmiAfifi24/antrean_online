import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/queue_entity.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> skipCurrentPatient(String doctorId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final queuesRef = _firestore.collection('queues');

    // Use transaction to avoid race conditions when computing max queue_number
    await _firestore.runTransaction((tx) async {
      // Find currently called patient
      final calledQuery = await queuesRef
          .where('doctor_id', isEqualTo: doctorId)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', isEqualTo: 'dipanggil')
          .limit(1)
          .get();

      if (calledQuery.docs.isEmpty) {
        throw Exception('no_called_patient');
      }

      final calledDoc = calledQuery.docs.first;
      final calledDocRef = queuesRef.doc(calledDoc.id);

      // Find current max queue_number among waiting patients
      final waitingMaxQuery = await queuesRef
          .where('doctor_id', isEqualTo: doctorId)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', isEqualTo: 'menunggu')
          .orderBy('queue_number', descending: true)
          .limit(1)
          .get();

      int maxQueueNumber = 0;
      if (waitingMaxQuery.docs.isNotEmpty) {
        final data = waitingMaxQuery.docs.first.data();
        final qn = data['queue_number'];
        if (qn is int) {
          maxQueueNumber = qn;
        } else if (qn is num) {
          maxQueueNumber = qn.toInt();
        }
      }

      final newQueueNumber = maxQueueNumber + 1;

      // Update the called document: set status back to waiting, record skipped_at, and move to end
      tx.update(calledDocRef, {
        'status': 'menunggu',
        'skipped_at': FieldValue.serverTimestamp(),
        'queue_number': newQueueNumber,
      });
    });
  }

  // The rest of the repository methods are not implemented here yet.
  @override
  Future<void> callNextPatient(String doctorId) {
    throw UnimplementedError();
  }

  @override
  Future<DoctorEntity> getDoctorProfile(String doctorId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<QueueEntity>> getTodayQueues(String doctorId) {
    throw UnimplementedError();
  }
}
