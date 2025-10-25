import '../entities/doctor_entity.dart';

abstract class PatientDoctorRepository {
  Future<List<DoctorEntity>> getAllDoctors();
  Future<List<DoctorEntity>> searchDoctors(String query);
}
