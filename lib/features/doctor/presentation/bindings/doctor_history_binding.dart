import 'package:get/get.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../domain/usecases/get_completed_queues.dart';
import '../controllers/doctor_history_controller.dart';

class DoctorHistoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DoctorRepository>()) {
      Get.lazyPut<DoctorRepository>(
        () => DoctorRepositoryImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetCompletedQueues>()) {
      Get.lazyPut<GetCompletedQueues>(
        () => GetCompletedQueues(Get.find<DoctorRepository>()),
        fenix: true,
      );
    }

    Get.lazyPut<DoctorHistoryController>(
      () => DoctorHistoryController(
        getCompletedQueues: Get.find<GetCompletedQueues>(),
      ),
      fenix: true,
    );
  }
}
