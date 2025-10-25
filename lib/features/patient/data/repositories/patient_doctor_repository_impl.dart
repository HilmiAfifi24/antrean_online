import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/patient_doctor_repository.dart';
import '../datasources/doctor_remote_datasource.dart';

class PatientDoctorRepositoryImpl implements PatientDoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  PatientDoctorRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DoctorEntity>> getAllDoctors() {
    return remoteDataSource.getAllDoctors();
  }

  @override
  Future<List<DoctorEntity>> searchDoctors(String query) {
    return remoteDataSource.searchDoctors(query);
  }
}
