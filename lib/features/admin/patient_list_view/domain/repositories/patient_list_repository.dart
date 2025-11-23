import '../entities/patient_list_entity.dart';

abstract class PatientListRepository {
  Stream<List<PatientListEntity>> getAllPatients();
  Future<List<PatientListEntity>> getAllPatientsOnce();
}
