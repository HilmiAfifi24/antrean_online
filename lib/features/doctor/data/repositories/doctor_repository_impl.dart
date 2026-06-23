import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/queue_entity.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _dayStart(DateTime date) => DateTime(date.year, date.month, date.day);

  Query<Map<String, dynamic>> _activeQueueQuery({
    required String doctorId,
    required DateTime date,
    required List<String> statuses,
  }) {
    return _firestore
        .collection('queues')
        .where('doctor_id', isEqualTo: doctorId)
        .where('appointment_date', isEqualTo: Timestamp.fromDate(_dayStart(date)))
        .where('status', whereIn: statuses)
        .orderBy('queue_number');
  }

  @override
  Future<DoctorEntity> getDoctorProfile(String doctorId) async {
    final query = await _firestore
        .collection('doctors')
        .where('user_id', isEqualTo: doctorId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Doctor profile not found');
    }

    final data = query.docs.first.data();
    return DoctorEntity(
      id: query.docs.first.id,
      name: data['nama_lengkap'] ?? '',
      specialization: data['spesialisasi'] ?? '',
      email: data['email'] ?? '',
    );
  }

  @override
  Stream<List<QueueEntity>> getTodayQueues(String doctorId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _firestore
        .collection('queues')
        .where('doctor_id', isEqualTo: doctorId)
        .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
        .where('status', whereIn: ['menunggu', 'waiting', 'dipanggil', 'ongoing', 'rescheduled'])
        .orderBy('queue_number')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return QueueEntity(
              id: doc.id,
              patientName: data['patient_name'] ?? '',
              queueNumber: data['queue_number'] ?? 0,
              status: data['status'] ?? '',
              complaint: data['complaint'] ?? '',
            );
          }).toList();
        });
  }

  @override
  Future<void> skipCurrentPatient(String doctorId) async {
    final today = DateTime.now();
    final queuesRef = _firestore.collection('queues');
    final dayStart = _dayStart(today);
    final calledSnapshot = await _firestore
        .collection('queues')
        .where('doctor_id', isEqualTo: doctorId)
        .where('appointment_date', isEqualTo: Timestamp.fromDate(dayStart))
        .where('status', isEqualTo: 'dipanggil')
        .orderBy('queue_number')
        .limit(1)
        .get();

    if (calledSnapshot.docs.isEmpty) {
      throw Exception('no_called_patient');
    }

    final maxSnapshot = await _firestore
        .collection('queues')
        .where('doctor_id', isEqualTo: doctorId)
        .where('appointment_date', isEqualTo: Timestamp.fromDate(dayStart))
        .orderBy('queue_number', descending: true)
        .limit(1)
        .get();

    final calledDoc = calledSnapshot.docs.first;
    final calledDocRef = queuesRef.doc(calledDoc.id);
    final maxDocRef = maxSnapshot.docs.isNotEmpty
        ? queuesRef.doc(maxSnapshot.docs.first.id)
        : null;
    final maxQueueNumber = _readQueueNumber(
      maxSnapshot.docs.isNotEmpty ? maxSnapshot.docs.first.data() : null,
    );

    await _firestore.runTransaction((tx) async {
      final liveCalledDoc = await tx.get(calledDocRef);
      if (!liveCalledDoc.exists) {
        throw Exception('no_called_patient');
      }

      final liveCalledData = liveCalledDoc.data() as Map<String, dynamic>;
      if ((liveCalledData['status'] ?? '') != 'dipanggil') {
        throw Exception('no_called_patient');
      }

      final newQueueNumber = maxQueueNumber + 1;
      if (maxDocRef != null) {
        final liveMaxDoc = await tx.get(maxDocRef);
        if (!liveMaxDoc.exists) {
          throw Exception('queue_snapshot_changed');
        }
      }

      tx.update(calledDocRef, {
        'status': 'menunggu',
        'skipped_at': FieldValue.serverTimestamp(),
        'queue_number': newQueueNumber,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  // The rest of the repository methods are not implemented here yet.
  @override
  Stream<List<QueueEntity>> getCompletedQueues(String doctorId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return _firestore
        .collection('queues')
        .where('doctor_id', isEqualTo: doctorId)
        .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
        .where('status', isEqualTo: 'selesai')
        .orderBy('completed_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return QueueEntity(
          id: doc.id,
          patientName: data['patient_name'] ?? '',
          queueNumber: data['queue_number'] ?? 0,
          status: data['status'] ?? '',
          complaint: data['complaint'] ?? '',
        );
      }).toList();
    });
  }

  @override
  Future<void> callNextPatient(String doctorId) async {
    final today = DateTime.now();
    final waitingSnapshot = await _activeQueueQuery(
      doctorId: doctorId,
      date: today,
      statuses: const ['menunggu', 'waiting', 'rescheduled'],
    )
        .limit(1)
        .get();

    if (waitingSnapshot.docs.isEmpty) {
      throw Exception('no_waiting_patient');
    }

    final queueDoc = waitingSnapshot.docs.first;

    await _firestore.runTransaction((tx) async {
      final liveQueueDoc = await tx.get(queueDoc.reference);
      if (!liveQueueDoc.exists) {
        throw Exception('no_waiting_patient');
      }

      final liveData = liveQueueDoc.data() as Map<String, dynamic>;
      final status = liveData['status'] ?? '';
      if (status != 'menunggu' && status != 'waiting' && status != 'rescheduled') {
        throw Exception('no_waiting_patient');
      }

      tx.update(queueDoc.reference, {
        'status': 'dipanggil',
        'called_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> completeCurrentPatient(String doctorId) async {
    final today = DateTime.now();
    final calledSnapshot = await _firestore
        .collection('queues')
        .where('doctor_id', isEqualTo: doctorId)
        .where('appointment_date', isEqualTo: Timestamp.fromDate(_dayStart(today)))
        .where('status', isEqualTo: 'dipanggil')
        .orderBy('queue_number')
        .limit(1)
        .get();

    if (calledSnapshot.docs.isEmpty) {
      throw Exception('no_called_patient');
    }

    final queueDoc = calledSnapshot.docs.first;

    await _firestore.runTransaction((tx) async {
      final liveQueueDoc = await tx.get(queueDoc.reference);
      if (!liveQueueDoc.exists) {
        throw Exception('no_called_patient');
      }

      final liveData = liveQueueDoc.data() as Map<String, dynamic>;
      if ((liveData['status'] ?? '') != 'dipanggil') {
        throw Exception('no_called_patient');
      }

      final patientId = (liveData['patient_id'] ?? '') as String;
      final queueDoctorId = (liveData['doctor_id'] ?? '') as String;
      if (patientId.isNotEmpty && queueDoctorId.isNotEmpty) {
        final patientLockRef = _firestore
            .collection('patient_queue_locks')
            .doc('${patientId}_$queueDoctorId');
        tx.delete(patientLockRef);
      }

      tx.update(queueDoc.reference, {
        'status': 'selesai',
        'completed_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<int> cancelDoctorSession(
    String doctorId,
    DateTime date,
    String reason,
  ) async {
    final startOfDay = _dayStart(date);
    final queueSnapshot = await _firestore
        .collection('queues')
        .where('doctor_id', isEqualTo: doctorId)
        .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
        .where('status', whereIn: [
          'menunggu',
          'waiting',
          'dipanggil',
          'ongoing',
          'rescheduled',
        ])
        .get();

    if (queueSnapshot.docs.isEmpty) {
      throw Exception('no_active_queue');
    }

    final affectedQueues = queueSnapshot.docs
        .map((doc) => <String, dynamic>{
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
    final scheduleCounts = <String, int>{};
    final scheduleRefs = <String, DocumentReference<Map<String, dynamic>>>{};
    final patientLockIds = <String>{};
    for (final doc in queueSnapshot.docs) {
      final data = doc.data();
      final scheduleId = (data['schedule_id'] ?? '') as String;
      if (scheduleId.isNotEmpty) {
        scheduleCounts[scheduleId] = (scheduleCounts[scheduleId] ?? 0) + 1;
        scheduleRefs[scheduleId] =
            _firestore.collection('schedules').doc(scheduleId);
      }
      final patientId = (data['patient_id'] ?? '') as String;
      final doctorQueueId = (data['doctor_id'] ?? '') as String;
      if (patientId.isNotEmpty && doctorQueueId.isNotEmpty) {
        patientLockIds.add('${patientId}_$doctorQueueId');
      }
    }

    return _firestore.runTransaction<int>((tx) async {
      final scheduleCurrentPatients = <String, int>{};
      for (final entry in scheduleRefs.entries) {
        final scheduleDoc = await tx.get(entry.value);
        if (!scheduleDoc.exists) {
          throw Exception('schedule_not_found');
        }

        final scheduleData = scheduleDoc.data();
        if ((scheduleData?['doctor_id'] ?? '') != doctorId) {
          throw Exception('schedule_doctor_mismatch');
        }

        scheduleCurrentPatients[entry.key] =
            (scheduleData?['current_patients'] as num?)?.toInt() ?? 0;
      }

      for (final doc in queueSnapshot.docs) {
        final liveQueueDoc = await tx.get(doc.reference);
        if (!liveQueueDoc.exists) {
          throw Exception('queue_snapshot_changed');
        }

        final liveQueueData = liveQueueDoc.data() as Map<String, dynamic>;
        final liveStatus = liveQueueData['status'] ?? '';
        if (liveQueueData['doctor_id'] != doctorId ||
            liveQueueData['appointment_date'] != Timestamp.fromDate(startOfDay) ||
            (liveStatus != 'menunggu' &&
                liveStatus != 'waiting' &&
                liveStatus != 'dipanggil' &&
                liveStatus != 'ongoing' &&
                liveStatus != 'rescheduled')) {
          throw Exception('queue_snapshot_changed');
        }

        tx.update(doc.reference, {
          'status': 'cancelled_by_doctor',
          'cancellation_reason': reason,
          'cancelled_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      for (final entry in scheduleCounts.entries) {
        final current = scheduleCurrentPatients[entry.key] ?? 0;
        final next = current - entry.value;
        tx.update(scheduleRefs[entry.key]!, {
          'current_patients': next > 0 ? next : 0,
        });
      }

      for (final queue in affectedQueues) {
        final notificationRef = _firestore.collection('patient_notifications').doc();
        tx.set(notificationRef, {
          'patient_id': queue['patient_id'] ?? '',
          'queue_id': queue['id'] ?? '',
          'doctor_id': queue['doctor_id'] ?? '',
          'doctor_name': queue['doctor_name'] ?? '',
          'schedule_id': queue['schedule_id'] ?? '',
          'title': 'Jadwal Dokter Dibatalkan',
          'message':
              'Jadwal dokter dibatalkan. Silakan lakukan penjadwalan ulang melalui aplikasi.',
          'reason': reason,
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      for (final lockId in patientLockIds) {
        tx.delete(_firestore.collection('patient_queue_locks').doc(lockId));
      }

      return affectedQueues.length;
    });
  }

  int _readQueueNumber(Map<String, dynamic>? data) {
    if (data == null) return 0;
    final value = data['queue_number'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
