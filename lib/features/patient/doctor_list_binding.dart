import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'data/datasources/doctor_remote_datasource.dart';
import 'data/repositories/patient_doctor_repository_impl.dart';
import 'domain/repositories/patient_doctor_repository.dart';
import 'domain/usecases/get_all_doctors.dart';
import 'presentation/controllers/doctor_list_controller.dart';

class DoctorListBinding extends Bindings {
  @override
  void dependencies() {
    // Firestore
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance);

    // Data Source
    Get.lazyPut<DoctorRemoteDataSource>(
      () => DoctorRemoteDataSource(Get.find()),
    );

    // Repository
    Get.lazyPut<PatientDoctorRepository>(
      () => PatientDoctorRepositoryImpl(Get.find()),
    );

    // Use Cases
    Get.lazyPut(() => GetAllDoctors(Get.find()));

    // Controller
    Get.lazyPut(() => DoctorListController(getAllDoctors: Get.find()));
  }
}
