import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'presentation/controllers/patient_admin_controller.dart';

class PatientAdminBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FirebaseFirestore>()) {
      Get.put(FirebaseFirestore.instance, permanent: true);
    }
    Get.put(PatientAdminController(firestore: Get.find()));
  }
}
