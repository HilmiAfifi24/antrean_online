import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'data/datasources/doctor_remote_datasource.dart';
import 'data/repositories/patient_doctor_repository_impl.dart';
import 'domain/repositories/patient_doctor_repository.dart';
import 'domain/usecases/get_doctor_schedules.dart';
import 'presentation/controllers/doctor_detail_controller.dart';

class DoctorDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Reuse existing instances if already registered (from DoctorListBinding)
    if (!Get.isRegistered<FirebaseFirestore>()) {
      Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance);
    }

    if (!Get.isRegistered<DoctorRemoteDataSource>()) {
      Get.lazyPut<DoctorRemoteDataSource>(
        () => DoctorRemoteDataSource(Get.find<FirebaseFirestore>()),
      );
    }

    if (!Get.isRegistered<PatientDoctorRepository>()) {
      Get.lazyPut<PatientDoctorRepository>(
        () => PatientDoctorRepositoryImpl(Get.find<DoctorRemoteDataSource>()),
      );
    }

    // Use case (specific to this page)
    Get.lazyPut(() => GetDoctorSchedules(Get.find<PatientDoctorRepository>()));

    // Controller
    Get.lazyPut<DoctorDetailController>(
      () => DoctorDetailController(getDoctorSchedules: Get.find()),
    );
  }
}
