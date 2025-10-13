import 'package:antrean_online/features/admin/doctor_view/data/datasources/doctor_admin_remote_datasource.dart';
import 'package:antrean_online/features/admin/doctor_view/data/models/doctor_admin_model.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';

class DoctorAdminRepositoryImpl implements DoctorAdminRepository {
  final DoctorAdminRemoteDatasource remoteDataSource;

  DoctorAdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DoctorAdminEntity>> getAllDoctors() async {
    final models = await remoteDataSource.getAllDoctors();
    return models.cast<DoctorAdminEntity>();
  }

  @override
  Future<DoctorAdminEntity?> getDoctorById(String id) async {
    final model = await remoteDataSource.getDoctorById(id);
    return model;
  }

  @override
  Future<String> addDoctor(DoctorAdminEntity doctor, String password) async {
    final model = DoctorAdminModel.fromEntity(doctor);
    return await remoteDataSource.addDoctor(model, password);
  }

  @override
  Future<void> updateDoctor(String id, DoctorAdminEntity doctor) async {
    final model = DoctorAdminModel.fromEntity(doctor);
    await remoteDataSource.updateDoctor(id, model);
  }

  @override
  Future<void> deleteDoctor(String id) async {
    await remoteDataSource.deleteDoctor(id);
  }

  @override
  Future<void> permanentlyDeleteDoctor(String id) async {
    await remoteDataSource.permanentlyDeleteDoctor(id);
  }

  @override
  Future<List<DoctorAdminEntity>> searchDoctors(String query) async {
    final models = await remoteDataSource.searchDoctors(query);
    return models.cast<DoctorAdminEntity>();
  }

  @override
  Future<List<DoctorAdminEntity>> getDoctorsBySpecialization(String specialization) async {
    final models = await remoteDataSource.getDoctorsBySpecialization(specialization);
    return models.cast<DoctorAdminEntity>();
  }

  @override
  Future<List<String>> getSpecializations() async {
    return await remoteDataSource.getSpecializations();
  }

  @override
  Future<bool> isIdentificationNumberExists(String nomorIdentifikasi, {String? excludeDoctorId}) async {
    return await remoteDataSource.isIdentificationNumberExists(nomorIdentifikasi, excludeDoctorId: excludeDoctorId);
  }

  @override
  Future<bool> isPhoneNumberExists(String nomorTelepon, {String? excludeDoctorId}) async {
    return await remoteDataSource.isPhoneNumberExists(nomorTelepon, excludeDoctorId: excludeDoctorId);
  }

  @override
  Future<bool> isEmailExists(String email, {String? excludeDoctorId}) async {
    return await remoteDataSource.isEmailExists(email, excludeDoctorId: excludeDoctorId);
  }
}
