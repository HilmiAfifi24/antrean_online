import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorProfile {
  final DoctorRepository repository;
  GetDoctorProfile(this.repository);

  Future<DoctorEntity> call(String doctorId) {
    return repository.getDoctorProfile(doctorId);
  }
}
