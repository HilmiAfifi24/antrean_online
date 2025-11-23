import '../entities/patient_list_entity.dart';
import '../repositories/patient_list_repository.dart';

class GetAllPatients {
  final PatientListRepository repository;

  GetAllPatients(this.repository);

  Stream<List<PatientListEntity>> call() {
    return repository.getAllPatients();
  }
}
