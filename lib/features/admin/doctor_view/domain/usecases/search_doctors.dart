import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';

class SearchDoctors {
  final DoctorAdminRepository repository;

  SearchDoctors(this.repository);

  Future<List<DoctorAdminEntity>> call(String query) {
    return repository.searchDoctors(query);
  }
}