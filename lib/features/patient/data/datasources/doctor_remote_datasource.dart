import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor_entity.dart';

class DoctorRemoteDataSource {
  final FirebaseFirestore firestore;

  DoctorRemoteDataSource(this.firestore);

  // Get all active doctors
  Future<List<DoctorEntity>> getAllDoctors() async {
    try {
      final snapshot = await firestore
          .collection('doctors')
          .where('is_active', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DoctorEntity(
          id: doc.id,
          name: data['name'] ?? '',
          specialization: data['specialization'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          isActive: data['is_active'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load doctors: $e');
    }
  }

  // Search doctors by name or specialization
  Future<List<DoctorEntity>> searchDoctors(String query) async {
    try {
      final snapshot = await firestore
          .collection('doctors')
          .where('is_active', isEqualTo: true)
          .get();

      final doctors = snapshot.docs.map((doc) {
        final data = doc.data();
        return DoctorEntity(
          id: doc.id,
          name: data['name'] ?? '',
          specialization: data['specialization'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          isActive: data['is_active'] ?? false,
        );
      }).toList();

      // Filter by name or specialization
      return doctors.where((doctor) =>
        doctor.name.toLowerCase().contains(query.toLowerCase()) ||
        doctor.specialization.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search doctors: $e');
    }
  }
}
