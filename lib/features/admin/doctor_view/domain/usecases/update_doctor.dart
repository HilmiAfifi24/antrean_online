import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';

class UpdateDoctor {
  final DoctorAdminRepository repository;

  UpdateDoctor(this.repository);

  Future<void> call(String id, DoctorAdminEntity doctor) {
    return repository.updateDoctor(id, doctor);
  }
}