import 'package:antrean_online/features/admin/schedule_view/data/models/schedule_admin_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleAdminRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ScheduleAdminRemoteDatasource({
    required this.firestore,
    required this.auth,
  });

  /// Get all schedules
  Future<List<ScheduleAdminModel>> getAllSchedules({bool includeInactive = false}) async {
    Query query = firestore.collection('schedules');

    if (!includeInactive) {
      query = query.where('is_active', isEqualTo: true);
    }

    final snapshot = await query.get();
    List<ScheduleAdminModel> schedules = snapshot.docs.map((doc) => ScheduleAdminModel.fromFirestore(doc)).toList();
    
    // Sort in memory to avoid composite index requirement
    schedules.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return schedules;
  }

  /// Get schedule by ID
  Future<ScheduleAdminModel?> getScheduleById(String id) async {
    final doc = await firestore.collection('schedules').doc(id).get();
    if (!doc.exists) return null;
    return ScheduleAdminModel.fromFirestore(doc);
  }

  /// Add new schedule
  Future<String> addSchedule(ScheduleAdminModel schedule) async {
    final docRef = await firestore.collection('schedules').add(schedule.toFirestore());

    await _logActivity(
      title: 'Jadwal Baru Ditambahkan',
      subtitle: 'Jadwal untuk ${schedule.doctorName} berhasil dibuat',
      type: 'schedule_added',
    );

    return docRef.id;
  }

  /// Update schedule
  Future<void> updateSchedule(String id, ScheduleAdminModel schedule) async {
    await firestore.collection('schedules').doc(id).update(schedule.toFirestoreForUpdate());

    await _logActivity(
      title: 'Jadwal Diperbarui',
      subtitle: 'Jadwal untuk ${schedule.doctorName} telah diperbarui',
      type: 'schedule_updated',
    );
  }

  /// Soft delete schedule (mark inactive)
  Future<void> deleteSchedule(String id) async {
    final schedule = await getScheduleById(id);
    if (schedule == null) throw Exception('Schedule not found');

    await firestore.collection('schedules').doc(id).update({
      'is_active': false,
      'updated_at': FieldValue.serverTimestamp(),
    });

    await _logActivity(
      title: 'Jadwal Dihapus',
      subtitle: 'Jadwal untuk ${schedule.doctorName} dinonaktifkan',
      type: 'schedule_deleted',
    );
  }

  /// Activate schedule (restore from soft delete)
  Future<void> activateSchedule(String id) async {
    final schedule = await getScheduleById(id);
    if (schedule == null) throw Exception('Schedule not found');

    await firestore.collection('schedules').doc(id).update({
      'is_active': true,
      'updated_at': FieldValue.serverTimestamp(),
    });

    await _logActivity(
      title: 'Jadwal Diaktifkan',
      subtitle: 'Jadwal untuk ${schedule.doctorName} telah diaktifkan kembali',
      type: 'schedule_activated',
    );
  }

  /// Search schedules by doctor name
  Future<List<ScheduleAdminModel>> searchSchedules(String query) async {
    final snapshot = await firestore
        .collection('schedules')
        .where('doctor_name', isGreaterThanOrEqualTo: query)
        .where('doctor_name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) => ScheduleAdminModel.fromFirestore(doc)).toList();
  }

  /// Get schedules by doctor ID
  Future<List<ScheduleAdminModel>> getSchedulesByDoctor(String doctorId) async {
    final snapshot = await firestore
        .collection('schedules')
        .where('doctor_id', isEqualTo: doctorId)
        .where('is_active', isEqualTo: true)
        .get();

    List<ScheduleAdminModel> schedules = snapshot.docs.map((doc) => ScheduleAdminModel.fromFirestore(doc)).toList();
    
    // Sort in memory to avoid composite index requirement
    schedules.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return schedules;
  }

  /// Private method to log activities
  Future<void> _logActivity({
    required String title,
    required String subtitle,
    required String type,
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    await firestore.collection('activities').add({
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'user_id': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
