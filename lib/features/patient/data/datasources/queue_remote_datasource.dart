import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/entities/schedule_entity.dart';

class QueueRemoteDataSource {
  final FirebaseFirestore firestore;
  static const duplicateBookingMessage =
      'Anda sudah memiliki antrean aktif dengan dokter ini pada tanggal tersebut.';

  QueueRemoteDataSource(this.firestore);

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isWaitingStatus(String status) {
    return status == 'menunggu' || status == 'waiting';
  }

  bool _canRescheduleStatus(String status) {
    return _isWaitingStatus(status) || status == 'cancelled_by_doctor';
  }

  bool _isCountedQueueStatus(String status) {
    return status == 'menunggu' ||
        status == 'waiting' ||
        status == 'dipanggil' ||
        status == 'ongoing' ||
        status == 'selesai' ||
        status == 'completed' ||
        status == 'rescheduled';
  }

  TimeOfDay _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeRange(Map<String, dynamic> schedule) {
    final start = schedule['start_time'] ?? '';
    final end = schedule['end_time'] ?? '';
    if (start.toString().isEmpty && end.toString().isEmpty) {
      return '';
    }
    return '$start - $end';
  }

  String _dayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }

  QueueEntity _queueFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
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
      queueNumber: (data['queue_number'] as num?)?.toInt() ?? 0,
      status: data['status'] ?? 'menunggu',
      complaint: data['complaint'] ?? '',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      rescheduledFrom: data['rescheduled_from'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['rescheduled_from'])
          : null,
      rescheduledAt: data['rescheduled_at'] != null
          ? (data['rescheduled_at'] as Timestamp).toDate()
          : null,
      cancellationReason: data['cancellation_reason'],
    );
  }

  // Get patient's active queues
  Future<List<QueueEntity>> getActiveQueues(String patientId) async {
    try {
      final querySnapshot = await firestore
          .collection('queues')
          .where('patient_id', isEqualTo: patientId)
          .where('status', whereIn: [
            'menunggu',
            'waiting',
            'dipanggil',
            'ongoing',
            'rescheduled',
          ])
          .orderBy('appointment_date')
          .orderBy('queue_number')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final now = DateTime.now();
      final today = _normalizeDate(now);
      final activeQueues = <QueueEntity>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final appointmentDate = data['appointment_date'] != null
            ? (data['appointment_date'] as Timestamp).toDate()
            : now;
        final appointmentDay = _normalizeDate(appointmentDate);

        if (appointmentDay.isBefore(today)) {
          await cancelQueue(doc.id, data['schedule_id'] ?? '');
          continue;
        }

        activeQueues.add(_queueFromDoc(doc));
      }

      return activeQueues;
    } catch (e) {
      throw Exception('Failed to get active queues: $e');
    }
  }

  Future<bool> validateMultipleBooking({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
  }) async {
    final normalizedDate = _normalizeDate(appointmentDate);
    final querySnapshot = await firestore
        .collection('queues')
        .where('patient_id', isEqualTo: patientId)
        .where('doctor_id', isEqualTo: doctorId)
        .where(
          'appointment_date',
          isEqualTo: Timestamp.fromDate(normalizedDate),
        )
        .where('status', whereIn: ['menunggu', 'dipanggil'])
        .limit(1)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  // Create new queue
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
  }) async {
    try {
      // Normalize date to start of day (remove time component)
      final normalizedDate = _normalizeDate(appointmentDate);

      final isValid = await validateMultipleBooking(
        patientId: patientId,
        doctorId: doctorId,
        appointmentDate: normalizedDate,
      );

      if (!isValid) {
        throw Exception(duplicateBookingMessage);
      }

      // Get the highest queue number for this schedule on this specific date
      // We don't filter by status because even cancelled queues take up a queue number
      final scheduleQueues = await firestore
          .collection('queues')
          .where('schedule_id', isEqualTo: scheduleId)
          .where(
            'appointment_date',
            isEqualTo: Timestamp.fromDate(normalizedDate),
          )
          .orderBy('queue_number', descending: true)
          .limit(1)
          .get();

      int queueNumber = 1;
      if (scheduleQueues.docs.isNotEmpty) {
        final data = scheduleQueues.docs.first.data();
        final qn = data['queue_number'];
        if (qn is int) {
          queueNumber = qn + 1;
        } else if (qn is num) {
          queueNumber = qn.toInt() + 1;
        }
      }

      // Create new queue document
      final docRef = await firestore.collection('queues').add({
        'patient_id': patientId,
        'patient_name': patientName,
        if (patientPhone != null) 'patient_phone': patientPhone,
        if (birthDate != null) 'birth_date': Timestamp.fromDate(birthDate),
        if (gender != null) 'gender': gender,
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
        'status': 'cancelled_by_patient',
        'cancelled_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel queue: $e');
    }
  }

  // Stream active queues
  Stream<List<QueueEntity>> watchActiveQueues(String patientId) {
    return firestore
        .collection('queues')
        .where('patient_id', isEqualTo: patientId)
        .where('status', whereIn: [
          'menunggu',
          'waiting',
          'dipanggil',
          'ongoing',
          'rescheduled',
        ])
        .orderBy('appointment_date')
        .orderBy('queue_number')
        .snapshots()
        .handleError((error) {
          // print(
          //   '[QueueRemoteDataSource] watchActiveQueues stream error: $error',
          // );
        })
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) {
            return <QueueEntity>[];
          }

          final now = DateTime.now();
          final today = _normalizeDate(now);
          final activeQueues = <QueueEntity>[];

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final appointmentDate = data['appointment_date'] != null
                ? (data['appointment_date'] as Timestamp).toDate()
                : now;
            final appointmentDay = _normalizeDate(appointmentDate);

            if (appointmentDay.isBefore(today)) {
              await cancelQueue(doc.id, data['schedule_id'] ?? '');
              continue;
            }

            activeQueues.add(_queueFromDoc(doc));
          }

          return activeQueues;
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
        .where(
          'appointment_date',
          isEqualTo: Timestamp.fromDate(normalizedDate),
        )
        .where('status', whereIn: ['dipanggil', 'ongoing', 'selesai', 'completed'])
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          final docs = snapshot.docs.map((d) => d.data()).toList();

          final calledDocs = docs
              .where((d) => d['status'] == 'dipanggil' || d['status'] == 'ongoing')
              .toList();
          if (calledDocs.isNotEmpty) {
            calledDocs.sort((a, b) {
              final aQueue = (a['queue_number'] as num?)?.toInt() ?? 999999;
              final bQueue = (b['queue_number'] as num?)?.toInt() ?? 999999;
              return aQueue.compareTo(bQueue);
            });
            return (calledDocs.first['queue_number'] as num?)?.toInt();
          }

          final completedDocs = docs
              .where((d) => d['status'] == 'selesai' || d['status'] == 'completed')
              .toList();
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
        .where(
          'appointment_date',
          isEqualTo: Timestamp.fromDate(normalizedDate),
        )
        .where('status', whereIn: [
          'menunggu',
          'waiting',
          'dipanggil',
          'ongoing',
          'rescheduled',
        ])
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
          .where('status', whereIn: [
            'selesai',
            'completed',
            'dibatalkan',
            'cancelled_by_patient',
            'cancelled_by_doctor',
          ])
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
          rescheduledFrom: data['rescheduled_from'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['rescheduled_from'])
              : null,
          rescheduledAt: data['rescheduled_at'] != null
              ? (data['rescheduled_at'] as Timestamp).toDate()
              : null,
          cancellationReason: data['cancellation_reason'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get queue history: $e');
    }
  }

  Future<void> validateRescheduleEligibility(String queueId) async {
    final queueDoc = await firestore.collection('queues').doc(queueId).get();
    if (!queueDoc.exists) {
      throw Exception('Antrean tidak ditemukan');
    }

    final data = queueDoc.data()!;
    final status = data['status'] ?? '';
    if (!_canRescheduleStatus(status)) {
      throw Exception('Hanya antrean menunggu yang dapat dijadwalkan ulang');
    }

    if (_isWaitingStatus(status)) {
      final appointmentDate = data['appointment_date'] != null
          ? (data['appointment_date'] as Timestamp).toDate()
          : DateTime.now();
      final today = _normalizeDate(DateTime.now());
      final appointmentDay = _normalizeDate(appointmentDate);
      if (appointmentDay.difference(today).inDays < 1) {
        throw Exception('Reschedule hanya dapat dilakukan maksimal H-1');
      }
    }
  }

  Future<List<ScheduleEntity>> getAvailableRescheduleDates(
    String queueId,
  ) async {
    await validateRescheduleEligibility(queueId);

    final queueDoc = await firestore.collection('queues').doc(queueId).get();
    final queue = queueDoc.data()!;
    final doctorId = queue['doctor_id'] ?? '';
    final oldDate = queue['appointment_date'] != null
        ? _normalizeDate((queue['appointment_date'] as Timestamp).toDate())
        : _normalizeDate(DateTime.now());

    final scheduleSnapshot = await firestore
        .collection('schedules')
        .where('doctor_id', isEqualTo: doctorId)
        .where('is_active', isEqualTo: true)
        .get();

    final today = _normalizeDate(DateTime.now());
    final candidates = <ScheduleEntity>[];
    for (final scheduleDoc in scheduleSnapshot.docs) {
      final schedule = scheduleDoc.data();
      final daysOfWeek = List<String>.from(schedule['days_of_week'] ?? []);
      final maxPatients = (schedule['max_patients'] as num?)?.toInt() ?? 0;

      for (var offset = 0; offset <= 60; offset++) {
        final date = today.add(Duration(days: offset));
        final normalized = _normalizeDate(date);
        if (normalized == oldDate) continue;
        if (daysOfWeek.isNotEmpty && !daysOfWeek.contains(_dayName(date))) {
          continue;
        }

        final queuesSnapshot = await firestore
            .collection('queues')
            .where('schedule_id', isEqualTo: scheduleDoc.id)
            .where(
              'appointment_date',
              isEqualTo: Timestamp.fromDate(normalized),
            )
            .get();

        final currentPatients = queuesSnapshot.docs
            .where((doc) => _isCountedQueueStatus(doc.data()['status'] ?? ''))
            .length;

        if (currentPatients >= maxPatients) continue;

        candidates.add(
          ScheduleEntity(
            id: scheduleDoc.id,
            doctorId: schedule['doctor_id'] ?? '',
            doctorName: schedule['doctor_name'] ?? '',
            doctorSpecialization: schedule['doctor_specialization'] ?? '',
            date: normalized,
            startTime: _parseTimeOfDay(schedule['start_time']),
            endTime: _parseTimeOfDay(schedule['end_time']),
            daysOfWeek: daysOfWeek,
            maxPatients: maxPatients,
            currentPatients: currentPatients,
            isActive: schedule['is_active'] ?? false,
          ),
        );
      }
    }

    candidates.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.startTime.hour != b.startTime.hour
          ? a.startTime.hour.compareTo(b.startTime.hour)
          : a.startTime.minute.compareTo(b.startTime.minute);
    });
    return candidates;
  }

  Future<QueueEntity> rescheduleQueue({
    required String queueId,
    required String newScheduleId,
    required DateTime newDate,
  }) async {
    final normalizedNewDate = _normalizeDate(newDate);
    try {
      final queueRef = firestore.collection('queues').doc(queueId);
      final newScheduleRef = firestore.collection('schedules').doc(newScheduleId);
      final newDateQueues = await firestore
          .collection('queues')
          .where('schedule_id', isEqualTo: newScheduleId)
          .where(
            'appointment_date',
            isEqualTo: Timestamp.fromDate(normalizedNewDate),
          )
          .get();

      final lastQueueDoc = await firestore
          .collection('queues')
          .where('schedule_id', isEqualTo: newScheduleId)
          .where(
            'appointment_date',
            isEqualTo: Timestamp.fromDate(normalizedNewDate),
          )
          .orderBy('queue_number', descending: true)
          .limit(1)
          .get();

      await firestore.runTransaction((transaction) async {
        final queueDoc = await transaction.get(queueRef);
        if (!queueDoc.exists) {
          throw Exception('Antrean tidak ditemukan');
        }

        final queue = queueDoc.data()!;
        final status = queue['status'] ?? '';
        if (!_canRescheduleStatus(status)) {
          throw Exception('Hanya antrean menunggu yang dapat dijadwalkan ulang');
        }

        final oldDate = queue['appointment_date'] != null
            ? _normalizeDate((queue['appointment_date'] as Timestamp).toDate())
            : _normalizeDate(DateTime.now());
        if (oldDate == normalizedNewDate) {
          throw Exception('Tanggal baru tidak boleh sama dengan tanggal lama');
        }

        final today = _normalizeDate(DateTime.now());
        if (normalizedNewDate.isBefore(today)) {
          throw Exception('Tidak boleh memilih tanggal yang sudah lewat');
        }

        if (_isWaitingStatus(status) && oldDate.difference(today).inDays < 1) {
          throw Exception('Reschedule hanya dapat dilakukan maksimal H-1');
        }

        final oldScheduleId = queue['schedule_id'] ?? '';
        final oldScheduleRef = firestore.collection('schedules').doc(oldScheduleId);
        final oldScheduleDoc = await transaction.get(oldScheduleRef);
        final newScheduleDoc = await transaction.get(newScheduleRef);
        if (!newScheduleDoc.exists) {
          throw Exception('Jadwal baru tidak ditemukan');
        }

        final newSchedule = newScheduleDoc.data()!;
        if ((newSchedule['doctor_id'] ?? '') != (queue['doctor_id'] ?? '')) {
          throw Exception('Pasien hanya dapat memilih jadwal dokter yang sama');
        }

        final maxPatients = (newSchedule['max_patients'] as num?)?.toInt() ?? 0;
        final occupied = newDateQueues.docs
            .where((doc) => doc.id != queueId)
            .where((doc) => _isCountedQueueStatus(doc.data()['status'] ?? ''))
            .length;
        if (occupied >= maxPatients) {
          throw Exception('Kuota pada tanggal tersebut sudah penuh');
        }

        var queueNumber = 1;
        if (lastQueueDoc.docs.isNotEmpty) {
          final lastNumber =
              (lastQueueDoc.docs.first.data()['queue_number'] as num?)
                      ?.toInt() ??
                  0;
          queueNumber = lastNumber + 1;
        }

        if (oldScheduleDoc.exists && oldScheduleRef.path != newScheduleRef.path) {
          final oldCurrent =
              (oldScheduleDoc.data()?['current_patients'] as num?)?.toInt() ??
                  0;
          final newCurrent =
              (newScheduleDoc.data()?['current_patients'] as num?)?.toInt() ??
                  0;
          transaction.update(oldScheduleRef, {
            'current_patients': oldCurrent > 0 ? oldCurrent - 1 : 0,
          });
          transaction.update(newScheduleRef, {
            'current_patients': newCurrent + 1,
          });
        }

        transaction.update(queueRef, {
          'schedule_id': newScheduleId,
          'appointment_date': Timestamp.fromDate(normalizedNewDate),
          'appointment_time': _formatTimeRange(newSchedule),
          'queue_number': queueNumber,
          'status': 'rescheduled',
          'rescheduled_from': {
            'schedule_id': oldScheduleId,
            'appointment_date': Timestamp.fromDate(oldDate),
            'queue_number': (queue['queue_number'] as num?)?.toInt() ?? 0,
            'status': status,
          },
          'rescheduled_at': FieldValue.serverTimestamp(),
          'cancellation_reason': FieldValue.delete(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      });

      final updatedDoc = await queueRef.get();
      return _queueFromDoc(updatedDoc);
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      throw Exception(message);
    }
  }
}
