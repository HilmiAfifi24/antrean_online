import '../entities/doctor_entity.dart';
import '../repositories/patient_doctor_repository.dart';

class GetAllPatientDoctors {
  final PatientDoctorRepository repository;

  GetAllPatientDoctors(this.repository);

  Future<List<DoctorEntity>> call() {
    return repository.getAllDoctors();
  }
}
