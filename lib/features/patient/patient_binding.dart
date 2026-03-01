import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/datasources/schedule_remote_datasource.dart';
import 'data/repositories/patient_schedule_repository_impl.dart';
import 'domain/repositories/patient_schedule_repository.dart';
import 'domain/usecases/get_all_schedules.dart';
import 'domain/usecases/get_schedules_by_day.dart';
import 'domain/usecases/get_schedules_by_day_stream.dart';
import 'domain/usecases/get_schedule_dates_stream.dart';
import 'domain/usecases/search_schedules.dart';
import 'presentation/controllers/patient_controller.dart';
import 'presentation/bindings/queue_binding.dart';

class PatientBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure Firestore instance available
    if (!Get.isRegistered<FirebaseFirestore>()) {
      Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);
    }

    // Data Layer
    Get.put<ScheduleRemoteDataSource>(
      ScheduleRemoteDataSource(Get.find<FirebaseFirestore>()),
      permanent: true,
    );

    // Repository Layer
    Get.put<PatientScheduleRepository>(
      PatientScheduleRepositoryImpl(Get.find<ScheduleRemoteDataSource>()),
      permanent: true,
    );

    // Use Cases Layer
    Get.put(
      GetAllSchedules(Get.find<PatientScheduleRepository>()),
      permanent: true,
    );
    Get.put(
      GetSchedulesByDay(Get.find<PatientScheduleRepository>()),
      permanent: true,
    );
    Get.put(
      GetSchedulesByDayStream(Get.find<PatientScheduleRepository>()),
      permanent: true,
    );
    Get.put(
      GetScheduleDatesStream(Get.find<PatientScheduleRepository>()),
      permanent: true,
    );
    Get.put(
      SearchSchedules(Get.find<PatientScheduleRepository>()),
      permanent: true,
    );

    // Controller Layer
    Get.put(
      PatientController(
        getAllSchedules: Get.find(),
        getSchedulesByDay: Get.find(),
        getSchedulesByDayStream: Get.find(),
        getScheduleDatesStream: Get.find(),
        searchSchedules: Get.find(),
      ),
      permanent: true,
    );

    // Initialize Queue Binding so QueueController is accessible everywhere
    // in the patient section (especially for checking active queue in modal)
    QueueBinding().dependencies();
  }
}
