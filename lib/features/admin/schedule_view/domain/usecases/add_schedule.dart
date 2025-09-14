import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';

class AddSchedule {
  final ScheduleAdminRepository repository;

  AddSchedule(this.repository);

  Future<String> call(ScheduleAdminEntity schedule) async {
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

    return await repository.addSchedule(schedule);
  }
}