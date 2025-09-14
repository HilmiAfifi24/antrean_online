import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';

abstract class ScheduleAdminRepository {
  Future<List<ScheduleAdminEntity>> getAllSchedules({bool includeInactive = false});
  Future<ScheduleAdminEntity?> getScheduleById(String id);
  Future<String> addSchedule(ScheduleAdminEntity schedule);
  Future<void> updateSchedule(String id, ScheduleAdminEntity schedule);
  Future<void> deleteSchedule(String id);
  Future<void> activateSchedule(String id);
  Future<List<ScheduleAdminEntity>> searchSchedules(String query);
  Future<List<ScheduleAdminEntity>> getSchedulesByDoctor(String doctorId);
}
