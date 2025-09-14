import 'package:antrean_online/features/admin/schedule_view/data/datasources/schedule_admin_remote_datsource.dart';
import 'package:antrean_online/features/admin/schedule_view/data/models/schedule_admin_model.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';

class ScheduleAdminRepositoryImpl implements ScheduleAdminRepository {
  final ScheduleAdminRemoteDatasource remoteDatasource;

  ScheduleAdminRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<ScheduleAdminEntity>> getAllSchedules({bool includeInactive = false}) async {
    final models = await remoteDatasource.getAllSchedules(includeInactive: includeInactive);
    return models;
  }

  @override
  Future<ScheduleAdminEntity?> getScheduleById(String id) async {
    final model = await remoteDatasource.getScheduleById(id);
    return model;
  }

  @override
  Future<String> addSchedule(ScheduleAdminEntity schedule) async {
    final model = ScheduleAdminModel.fromEntity(schedule);
    return await remoteDatasource.addSchedule(model);
  }

  @override
  Future<void> updateSchedule(String id, ScheduleAdminEntity schedule) async {
    final model = ScheduleAdminModel.fromEntity(schedule);
    await remoteDatasource.updateSchedule(id, model);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await remoteDatasource.deleteSchedule(id);
  }

  @override
  Future<void> activateSchedule(String id) async {
    await remoteDatasource.activateSchedule(id);
  }

  @override
  Future<List<ScheduleAdminEntity>> searchSchedules(String query) async {
    final models = await remoteDatasource.searchSchedules(query);
    return models;
  }

  @override
  Future<List<ScheduleAdminEntity>> getSchedulesByDoctor(String doctorId) async {
    final models = await remoteDatasource.getSchedulesByDoctor(doctorId);
    return models;
  }
}
