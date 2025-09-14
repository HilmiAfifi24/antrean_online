import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';

class SearchSchedules {
  final ScheduleAdminRepository repository;

  SearchSchedules(this.repository);

  Future<List<ScheduleAdminEntity>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    return await repository.searchSchedules(query.trim());
  }
}