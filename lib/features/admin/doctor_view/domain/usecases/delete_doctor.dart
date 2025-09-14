import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';

class DeleteDoctor {
  final DoctorAdminRepository repository;

  DeleteDoctor(this.repository);

  Future<void> call(String id) {
    return repository.deleteDoctor(id);
  }
}