import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';

class GetSchedulesByDoctor {
  final ScheduleAdminRepository repository;

  GetSchedulesByDoctor(this.repository);

  Future<List<ScheduleAdminEntity>> call(String doctorId) async {
    if (doctorId.trim().isEmpty) {
      throw Exception('ID dokter tidak boleh kosong');
    }

    return await repository.getSchedulesByDoctor(doctorId);
  }
}