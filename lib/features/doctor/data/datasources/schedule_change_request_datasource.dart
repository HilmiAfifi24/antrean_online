import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/schedule_change_request_entity.dart';

class ScheduleChangeRequestDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ScheduleChangeRequestDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String _buildLockId(String doctorId, String scheduleId) {
    return '${doctorId}_$scheduleId';
  }

  DocumentReference<Map<String, dynamic>> _lockRef(String lockId) {
    return _firestore
        .collection('schedule_change_request_locks')
        .doc(lockId);
  }


  List<String> _normalizeDays(List<dynamic> rawDays) {
    return rawDays
        .whereType<String>()
        .map((day) => day.trim())
        .where((day) => day.isNotEmpty)
        .toList();
  }

  Future<bool> _hasActiveQueuesForSchedule(String scheduleId) async {
    final snapshot = await _firestore
        .collection('queues')
        .where('schedule_id', isEqualTo: scheduleId)
        .where('status', whereIn: [
          'menunggu',
          'waiting',
          'dipanggil',
          'ongoing',
          'rescheduled',
        ])
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // ─── DOKTER: Submit request ────────────────────────────────────────────────

  Future<void> submitScheduleChangeRequest({
    required String oldScheduleId,
    required String oldDay,
    required String oldStartTime,
    required String oldEndTime,
    required String newDay,
    required String newStartTime,
    required String newEndTime,
    required String reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Pengguna tidak terautentikasi');

    final oldScheduleDoc = await _firestore
        .collection('schedules')
        .doc(oldScheduleId)
        .get();
    if (!oldScheduleDoc.exists) {
      throw Exception('Jadwal yang dipilih tidak ditemukan');
    }

    final oldScheduleData = oldScheduleDoc.data()!;
    if (oldScheduleData['doctor_id'] != user.uid) {
      throw Exception('Anda hanya dapat mengajukan perubahan untuk jadwal milik sendiri');
    }

    final existingDays = _normalizeDays(oldScheduleData['days_of_week'] ?? []);
    final selectedOldDay = oldDay.trim();
    if (selectedOldDay.isEmpty || !existingDays.contains(selectedOldDay)) {
      throw Exception('Hari yang dipilih tidak tersedia pada jadwal ini');
    }

    final conflict = await validateScheduleConflict(
      doctorId: user.uid,
      oldScheduleId: oldScheduleId,
      newDay: newDay.trim(),
      newStartTime: newStartTime,
      newEndTime: newEndTime,
    );
    if (conflict != null) {
      throw Exception(conflict);
    }

    String doctorName = '';
    String doctorPhone = '';
    final doctorDoc = await _firestore.collection('doctors').where('user_id', isEqualTo: user.uid).limit(1).get();
    if (doctorDoc.docs.isNotEmpty) {
      final data = doctorDoc.docs.first.data();
      doctorName = data['nama_lengkap'] ?? '';
      doctorPhone = data['nomor_telepon'] ?? '';
    }

    final lockId = _buildLockId(user.uid, oldScheduleId);
    final lockRef = _lockRef(lockId);
    final requestRef = _firestore.collection('schedule_change_requests').doc();


    await _firestore.runTransaction((tx) async {
      final latestSchedule = await tx.get(oldScheduleDoc.reference);
      if (!latestSchedule.exists) {
        throw Exception('Jadwal yang dipilih tidak ditemukan');
      }

      final latestScheduleData = latestSchedule.data()!;
      if (latestScheduleData['doctor_id'] != user.uid) {
        throw Exception('Anda hanya dapat mengajukan perubahan untuk jadwal milik sendiri');
      }
      if (latestScheduleData['is_active'] == false) {
        throw Exception('Jadwal yang dipilih sedang tidak aktif');
      }

      final lockSnapshot = await tx.get(lockRef);
      if (lockSnapshot.exists) {
        throw Exception(
          'Anda sudah memiliki permintaan perubahan yang sedang menunggu untuk jadwal ini',
        );
      }

      tx.set(lockRef, {
        'doctor_id': user.uid,
        'schedule_id': oldScheduleId,
        'request_id': requestRef.id,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      tx.set(requestRef, {
        'doctor_id': user.uid,
        'doctor_name': doctorName,
        'doctor_phone': doctorPhone,
        'old_schedule_id': oldScheduleId,
        'old_day': selectedOldDay,
        'old_start_time': oldStartTime,
        'old_end_time': oldEndTime,
        'new_day': newDay.trim(),
        'new_start_time': newStartTime,
        'new_end_time': newEndTime,
        'reason': reason,
        'status': 'pending',
        'lock_id': lockId,
        'admin_approver_id': null,
        'rejection_reason': null,
        'created_at': FieldValue.serverTimestamp(),
        'approved_at': null,
      });
    });
  }

  // ─── DOKTER: Stream riwayat request milik dokter yang login ───────────────

  Stream<List<ScheduleChangeRequestEntity>> streamMyRequests() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('schedule_change_requests')
        .where('doctor_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ScheduleChangeRequestEntity.fromFirestore(doc))
              .toList(),
        );
  }

  // ─── DOKTER: Ambil jadwal aktif milik dokter yang login ────────────────────

  Future<List<Map<String, dynamic>>> getMyActiveSchedules() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Pengguna tidak terautentikasi');

    final snap = await _firestore
        .collection('schedules')
        .where('doctor_id', isEqualTo: user.uid)
        .where('is_active', isEqualTo: true)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ─── ADMIN: Stream semua request (dengan filter status opsional) ───────────

  Stream<List<ScheduleChangeRequestEntity>> streamAllRequests({
    String? statusFilter,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('schedule_change_requests')
        .orderBy('created_at', descending: true);

    if (statusFilter != null && statusFilter.isNotEmpty) {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => ScheduleChangeRequestEntity.fromFirestore(doc))
              .toList(),
        );
  }

  // ─── ADMIN: Validasi konflik jadwal ────────────────────────────────────────

  Future<String?> validateScheduleConflict({
    required String doctorId,
    required String oldScheduleId,
    required String newDay,
    required String newStartTime,
    required String newEndTime,
  }) async {
    // Ambil data jadwal lama untuk mendapatkan roomId dan poliId
    final oldScheduleDoc =
        await _firestore.collection('schedules').doc(oldScheduleId).get();
    if (!oldScheduleDoc.exists) {
      return 'Jadwal lama tidak ditemukan';
    }
    final oldData = oldScheduleDoc.data()!;
    final roomId = oldData['room_id'] ?? '';
    final poliId = oldData['poli_id'] ?? '';

    // Helper: konversi "HH:mm" ke menit
    int toMinutes(String time) {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final newStart = toMinutes(newStartTime);
    final newEnd = toMinutes(newEndTime);

    // Ambil semua jadwal aktif
    final allSchedules = await _firestore
        .collection('schedules')
        .where('is_active', isEqualTo: true)
        .get();

    for (final doc in allSchedules.docs) {
      // Lewati jadwal lama yang sedang diganti
      if (doc.id == oldScheduleId) continue;

      final data = doc.data();
      final existingDays = List<String>.from(data['days_of_week'] ?? []);
      if (!existingDays.contains(newDay)) continue;

      final existingStart = toMinutes(data['start_time'] ?? '00:00');
      final existingEnd = toMinutes(data['end_time'] ?? '00:00');

      // Cek overlap waktu
      final hasTimeOverlap =
          newStart < existingEnd && newEnd > existingStart;

      if (!hasTimeOverlap) continue;

      final existingRoomId = data['room_id'] ?? '';
      final existingPoliId = data['poli_id'] ?? '';
      final existingDoctorId = data['doctor_id'] ?? '';

      // Konflik 1: room yang sama
      if (roomId.isNotEmpty && existingRoomId == roomId) {
        return 'Jadwal bentrok dengan sesi praktik lain di ruang yang sama';
      }

      // Konflik 2: poli yang sama
      if (poliId.isNotEmpty && existingPoliId == poliId) {
        return 'Jadwal bentrok dengan sesi praktik lain di poli yang sama';
      }

      // Konflik 3: dokter yang sama punya 2 jadwal aktif di waktu yg sama
      if (existingDoctorId == doctorId) {
        return 'Anda sudah memiliki jadwal aktif di waktu yang sama';
      }
    }

    return null; // Tidak ada konflik
  }

  // ─── ADMIN: Approve request ────────────────────────────────────────────────

  Future<void> approveScheduleChange({
    required String requestId,
    required String adminId,
  }) async {
    final requestDoc = await _firestore
        .collection('schedule_change_requests')
        .doc(requestId)
        .get();
    if (!requestDoc.exists) throw Exception('Request tidak ditemukan');

    final request = ScheduleChangeRequestEntity.fromFirestore(requestDoc);

    if (await _hasActiveQueuesForSchedule(request.oldScheduleId)) {
      throw Exception(
        'Jadwal ini masih memiliki antrean aktif. Selesaikan atau pindahkan antrean terlebih dahulu sebelum menyetujui perubahan.',
      );
    }

    // Validasi konflik sebelum approve
    final conflict = await validateScheduleConflict(
      doctorId: request.doctorId,
      oldScheduleId: request.oldScheduleId,
      newDay: request.newDay,
      newStartTime: request.newStartTime,
      newEndTime: request.newEndTime,
    );

    if (conflict != null) throw Exception(conflict);

    final requestData = requestDoc.data() as Map<String, dynamic>;
    final lockId = (requestData['lock_id'] as String?) ??
        _buildLockId(request.doctorId, request.oldScheduleId);
    final lockRef = _lockRef(lockId);
    final oldScheduleRef =
        _firestore.collection('schedules').doc(request.oldScheduleId);
    final notificationRef = _firestore.collection('doctor_notifications').doc();

    await _firestore.runTransaction((tx) async {
      // 1. Perform all reads first
      final latestRequest = await tx.get(requestDoc.reference);
      final latestLock = await tx.get(lockRef);
      final oldScheduleDoc = await tx.get(oldScheduleRef);

      // 2. Perform validations
      if (!latestRequest.exists) {
        throw Exception('Request tidak ditemukan');
      }
      final latestRequestData = latestRequest.data() as Map<String, dynamic>;
      if (latestRequestData['status'] != 'pending') {
        throw Exception('Request sudah diproses');
      }

      if (!oldScheduleDoc.exists) {
        throw Exception('Jadwal lama tidak ditemukan');
      }

      final oldScheduleData = oldScheduleDoc.data()!;
      if (oldScheduleData['doctor_id'] != request.doctorId) {
        throw Exception('Request tidak valid untuk dokter ini');
      }

      final oldDays = _normalizeDays(oldScheduleData['days_of_week'] ?? []);
      if (!oldDays.contains(request.oldDay)) {
        throw Exception('Hari jadwal yang diminta tidak tersedia pada jadwal lama');
      }

      // 3. Perform all writes
      final remainingDays =
          oldDays.where((day) => day != request.oldDay).toList();

      final newScheduleRef = _firestore.collection('schedules').doc();

      if (remainingDays.isEmpty) {
        tx.update(oldScheduleRef, {
          'days_of_week': remainingDays,
          'is_active': false,
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(oldScheduleRef, {
          'days_of_week': remainingDays,
          'is_active': true,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      tx.set(newScheduleRef, {
        ...oldScheduleData,
        'days_of_week': [request.newDay],
        'start_time': request.newStartTime,
        'end_time': request.newEndTime,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'source_request_id': requestId,
        'split_from_schedule_id': request.oldScheduleId,
        'split_from_day': request.oldDay,
      });

      tx.update(requestDoc.reference, {
        'status': 'approved',
        'admin_approver_id': adminId,
        'approved_at': FieldValue.serverTimestamp(),
        'rejected_at': null,
        'new_schedule_id': newScheduleRef.id,
        'lock_id': lockId,
      });

      if (latestLock.exists) {
        final latestLockData = latestLock.data() as Map<String, dynamic>;
        if (latestLockData['status'] == 'pending' &&
            latestLockData['request_id'] == requestId) {
          tx.delete(lockRef);
        }
      }

      tx.set(notificationRef, {
        'doctor_id': request.doctorId,
        'title': 'Perubahan Jadwal Disetujui ✅',
        'body':
            'Permintaan perubahan jadwal hari ${request.oldDay} (${request.oldStartTime}–${request.oldEndTime}) ke ${request.newDay} (${request.newStartTime}–${request.newEndTime}) telah disetujui.',
        'type': 'schedule_change_approved',
        'request_id': requestId,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    });
  }

  // ─── ADMIN: Reject request ─────────────────────────────────────────────────

  Future<void> rejectScheduleChange({
    required String requestId,
    required String adminId,
    required String rejectionReason,
  }) async {
    final requestDoc = await _firestore
        .collection('schedule_change_requests')
        .doc(requestId)
        .get();
    if (!requestDoc.exists) throw Exception('Request tidak ditemukan');

    final request = ScheduleChangeRequestEntity.fromFirestore(requestDoc);
    final requestData = requestDoc.data() as Map<String, dynamic>;
    final lockId = (requestData['lock_id'] as String?) ??
        _buildLockId(request.doctorId, request.oldScheduleId);
    final lockRef = _lockRef(lockId);
    final notificationRef = _firestore.collection('doctor_notifications').doc();

    await _firestore.runTransaction((tx) async {
      // 1. Perform all reads first
      final latestRequest = await tx.get(requestDoc.reference);
      final latestLock = await tx.get(lockRef);

      // 2. Perform validations
      if (!latestRequest.exists) {
        throw Exception('Request tidak ditemukan');
      }
      final latestRequestData = latestRequest.data() as Map<String, dynamic>;
      if (latestRequestData['status'] != 'pending') {
        throw Exception('Request sudah diproses');
      }

      // 3. Perform all writes
      tx.update(requestDoc.reference, {
        'status': 'rejected',
        'admin_approver_id': adminId,
        'rejection_reason': rejectionReason,
        'rejected_at': FieldValue.serverTimestamp(),
        'approved_at': null,
      });

      if (latestLock.exists) {
        final latestLockData = latestLock.data() as Map<String, dynamic>;
        if (latestLockData['status'] == 'pending' &&
            latestLockData['request_id'] == requestId) {
          tx.delete(lockRef);
        }
      }

      tx.set(notificationRef, {
        'doctor_id': request.doctorId,
        'title': 'Perubahan Jadwal Ditolak ❌',
        'body':
            'Permintaan perubahan jadwal Anda ditolak. Alasan: $rejectionReason',
        'type': 'schedule_change_rejected',
        'request_id': requestId,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    });
  }

  // ─── DOKTER: Stream notifikasi ────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> streamDoctorNotifications() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('doctor_notifications')
        .where('doctor_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _firestore
        .collection('doctor_notifications')
        .doc(notificationId)
        .update({'is_read': true});
  }
}
