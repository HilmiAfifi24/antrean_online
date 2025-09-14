import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';

class ActivateSchedule {
  final ScheduleAdminRepository repository;

  ActivateSchedule(this.repository);

  Future<void> call(String id) async {
    // Validation: Check if schedule exists
    final schedule = await repository.getScheduleById(id);
    if (schedule == null) {
      throw Exception('Jadwal tidak ditemukan');
    }

    // Validation: Check if schedule is already active
    if (schedule.isActive) {
      throw Exception('Jadwal sudah aktif');
    }

    await repository.activateSchedule(id);
  }
}