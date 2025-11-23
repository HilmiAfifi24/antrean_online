import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/patient_list_view_controller.dart';
import '../../data/datasources/patient_list_remote_datasource.dart';
import '../../data/repositories/patient_list_repository_impl.dart';
import '../../domain/usecases/get_all_patients.dart';

class PatientListViewBinding extends Bindings {
  @override
  void dependencies() {
    // Register datasource
    Get.lazyPut<PatientListRemoteDataSource>(
      () => PatientListRemoteDataSource(Get.find<FirebaseFirestore>()),
    );

    // Register repository
    Get.lazyPut<PatientListRepositoryImpl>(
      () => PatientListRepositoryImpl(Get.find()),
    );

    // Register usecase
    Get.lazyPut<GetAllPatients>(
      () => GetAllPatients(Get.find<PatientListRepositoryImpl>()),
    );

    // Register controller
    Get.lazyPut<PatientListViewController>(
      () => PatientListViewController(getAllPatients: Get.find()),
    );
  }
}
