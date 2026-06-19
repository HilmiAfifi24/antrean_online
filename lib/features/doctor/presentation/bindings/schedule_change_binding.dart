import 'package:get/get.dart';
import '../controllers/schedule_change_controller.dart';

class ScheduleChangeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleChangeController>(() => ScheduleChangeController());
  }
}
