import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';

abstract class DoctorAdminRepository {
  Future<List<DoctorAdminEntity>> getAllDoctors();
  Future<DoctorAdminEntity?> getDoctorById(String id);
  Future<String> addDoctor(DoctorAdminEntity doctor, String password);
  Future<void> updateDoctor(String id, DoctorAdminEntity doctor);
  Future<void> deleteDoctor(String id);
  Future<List<DoctorAdminEntity>> searchDoctors(String query);
  Future<List<DoctorAdminEntity>> getDoctorsBySpecialization(String specialization);
  Future<List<String>> getSpecializations();

  // Method tambahan untuk manajemen penuh dokter
  Future<void> permanentlyDeleteDoctor(String id);
}
