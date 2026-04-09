import '../repositories/patient_doctor_repository.dart';

class GetDoctorSchedules {
  final PatientDoctorRepository repository;

  GetDoctorSchedules(this.repository);

  Future<List<Map<String, dynamic>>> call(String doctorId) {
    return repository.getDoctorSchedules(doctorId);
  }
}
