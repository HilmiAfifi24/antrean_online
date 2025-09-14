import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';

class GetScheduleById {
  final ScheduleAdminRepository repository;

  GetScheduleById(this.repository);

  Future<ScheduleAdminEntity?> call(String id) async {
    return await repository.getScheduleById(id);
  }
}