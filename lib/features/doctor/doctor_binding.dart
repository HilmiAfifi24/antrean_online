import 'package:get/get.dart';
import 'data/repositories/doctor_repository_impl.dart';
import 'domain/repositories/doctor_repository.dart';
import 'presentation/controllers/doctor_controller.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DoctorRepository>()) {
      Get.lazyPut<DoctorRepository>(
        () => DoctorRepositoryImpl(),
        fenix: true,
      );
    }

    Get.lazyPut<DoctorController>(
      () => DoctorController(doctorRepository: Get.find<DoctorRepository>()),
      fenix: true,
    );
  }
}
