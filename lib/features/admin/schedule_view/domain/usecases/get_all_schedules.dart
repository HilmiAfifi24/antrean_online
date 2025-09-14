import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';

class GetAllSchedules {
  final ScheduleAdminRepository repository;

  GetAllSchedules(this.repository);

  Future<List<ScheduleAdminEntity>> call({bool includeInactive = false}) async {
    return await repository.getAllSchedules(includeInactive: includeInactive);
  }
}