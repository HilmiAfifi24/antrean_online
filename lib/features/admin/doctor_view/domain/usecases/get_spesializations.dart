import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';

class GetSpecializations {
  final DoctorAdminRepository repository;

  GetSpecializations(this.repository);

  Future<List<String>> call() {
    return repository.getSpecializations();
  }
}