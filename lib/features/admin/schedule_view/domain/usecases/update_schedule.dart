import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';

class UpdateSchedule {
  final ScheduleAdminRepository repository;

  UpdateSchedule(this.repository);

  Future<void> call(String id, ScheduleAdminEntity schedule) async {
    // Validation: Check if schedule exists
    final existingSchedule = await repository.getScheduleById(id);
    if (existingSchedule == null) {
      throw Exception('Jadwal tidak ditemukan');
    }

    // Validation: Check if end time is after start time
    if (schedule.endTime.hour < schedule.startTime.hour || 
        (schedule.endTime.hour == schedule.startTime.hour && 
         schedule.endTime.minute <= schedule.startTime.minute)) {
      throw Exception('Waktu selesai harus lebih besar dari waktu mulai');
    }

    // Validation: Check max patients
    if (schedule.maxPatients <= 0) {
      throw Exception('Maksimal pasien harus lebih dari 0');
    }

    // Validation: Check days of week
    if (schedule.daysOfWeek.isEmpty) {
      throw Exception('Pilih minimal satu hari dalam seminggu');
    }

    // Validation: Don't allow reducing max patients below current patients
    if (schedule.maxPatients < existingSchedule.currentPatients) {
      throw Exception('Tidak dapat mengurangi maksimal pasien di bawah jumlah pasien saat ini (${existingSchedule.currentPatients})');
    }

    await repository.updateSchedule(id, schedule);
  }
}