import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/patient_list_entity.dart';

class PatientListModel extends PatientListEntity {
  const PatientListModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    required super.createdAt,
  });

  factory PatientListModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PatientListModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'pasien',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
