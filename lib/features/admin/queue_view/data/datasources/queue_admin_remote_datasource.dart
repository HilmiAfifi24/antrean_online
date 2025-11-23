import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/queue_admin_model.dart';

class QueueAdminRemoteDataSource {
  final FirebaseFirestore firestore;

  QueueAdminRemoteDataSource(this.firestore);

  // Get queues by date as a stream (realtime)
  Stream<List<QueueAdminModel>> getQueuesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);

    return firestore
        .collection('queues')
        .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('queue_number')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QueueAdminModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get queues by date once (not realtime)
  Future<List<QueueAdminModel>> getQueuesByDateOnce(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final snapshot = await firestore
        .collection('queues')
        .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('queue_number')
        .get();

    return snapshot.docs
        .map((doc) => QueueAdminModel.fromFirestore(doc))
        .toList();
  }
}
