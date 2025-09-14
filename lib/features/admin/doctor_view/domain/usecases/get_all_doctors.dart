import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';

class GetAllDoctors {
  final DoctorAdminRepository repository;

  GetAllDoctors(this.repository);

  Future<List<DoctorAdminEntity>> call() {
    return repository.getAllDoctors();
  }
}