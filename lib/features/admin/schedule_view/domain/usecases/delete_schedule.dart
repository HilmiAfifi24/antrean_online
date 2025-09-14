import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';

class DeleteSchedule {
  final ScheduleAdminRepository repository;

  DeleteSchedule(this.repository);

  Future<void> call(String id) async {
    // Validation: Check if schedule exists
    final schedule = await repository.getScheduleById(id);
    if (schedule == null) {
      throw Exception('Jadwal tidak ditemukan');
    }

    // Validation: Don't allow deleting schedule with active patients
    if (schedule.currentPatients > 0) {
      throw Exception('Tidak dapat menghapus jadwal yang masih memiliki pasien aktif (${schedule.currentPatients} pasien)');
    }

    await repository.deleteSchedule(id);
  }
}