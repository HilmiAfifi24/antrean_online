import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';

class GetDoctorById {
  final DoctorAdminRepository repository;

  GetDoctorById(this.repository);

  Future<DoctorAdminEntity?> call(String id) {
    return repository.getDoctorById(id);
  }
}