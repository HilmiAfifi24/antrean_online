import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSource(this.firestore);

  // Get total patients count
  Future<int> getTotalPatients() async {
    final snapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: 'pasien')
        .get();
    return snapshot.docs.length;
  }

  // Get total doctors count
  Future<int> getTotalDoctors() async {
    try {
      // Ambil langsung dari collection doctors yang aktif
      final snapshot = await firestore
          .collection('doctors')
          .where('is_active', isEqualTo: true)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      // print('Error getting total doctors: $e');
      return 0;
    }
  }

  // Get total schedules count
  Future<int> getTotalSchedules() async {
    final snapshot = await firestore
        .collection('schedules')
        .where('is_active', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  // Get total queues count
  Future<int> getTotalQueues() async {
    final snapshot = await firestore.collection('queues').get();
    return snapshot.docs.length;
  }

  // Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    final snapshot = await firestore
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'title': data['title'] ?? '',
        'subtitle': data['subtitle'] ?? '',
        'time': _formatTime(data['timestamp'] as Timestamp?),
        'type': data['type'] ?? 'default',
      };
    }).toList();
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';

    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }

  // Add activity log (untuk tracking aktivitas admin)
  Future<void> logActivity({
    required String title,
    required String subtitle,
    required String type,
  }) async {
    await firestore.collection('activities').add({
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
