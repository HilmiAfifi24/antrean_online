import '../entities/doctor_entity.dart';
import '../repositories/patient_doctor_repository.dart';

class GetAllDoctors {
  final PatientDoctorRepository repository;

  GetAllDoctors(this.repository);

  Future<List<DoctorEntity>> call() {
    return repository.getAllDoctors();
  }
}
