import '../../domain/entities/patient_list_entity.dart';
import '../../domain/repositories/patient_list_repository.dart';
import '../datasources/patient_list_remote_datasource.dart';

class PatientListRepositoryImpl implements PatientListRepository {
  final PatientListRemoteDataSource dataSource;

  PatientListRepositoryImpl(this.dataSource);

  @override
  Stream<List<PatientListEntity>> getAllPatients() {
    return dataSource.getAllPatients();
  }

  @override
  Future<List<PatientListEntity>> getAllPatientsOnce() {
    return dataSource.getAllPatientsOnce();
  }
}
