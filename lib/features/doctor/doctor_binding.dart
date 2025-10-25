import 'package:get/get.dart';
import 'presentation/controllers/doctor_controller.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorController>(() => DoctorController());
  }
}
