import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_list_model.dart';

class PatientListRemoteDataSource {
  final FirebaseFirestore firestore;

  PatientListRemoteDataSource(this.firestore);

  // Get all patients as a stream (realtime)
  Stream<List<PatientListModel>> getAllPatients() {
    return firestore
        .collection('users')
        .where('role', isEqualTo: 'pasien')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PatientListModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all patients once (not realtime)
  Future<List<PatientListModel>> getAllPatientsOnce() async {
    final snapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: 'pasien')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PatientListModel.fromFirestore(doc))
        .toList();
  }
}
