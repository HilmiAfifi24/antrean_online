import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';

class AddDoctor {
  final DoctorAdminRepository repository;

  AddDoctor(this.repository);

  Future<String> call(DoctorAdminEntity doctor) {
    return repository.addDoctor(doctor);
  }
}