import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/datasources/schedule_remote_datasource.dart';
import 'data/repositories/patient_schedule_repository_impl.dart';
import 'domain/repositories/patient_schedule_repository.dart';
import 'domain/usecases/get_all_schedules.dart';
import 'domain/usecases/get_schedules_by_day.dart';
import 'domain/usecases/search_schedules.dart';
import 'presentation/controllers/patient_controller.dart';

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
    Get.put(GetAllSchedules(Get.find<PatientScheduleRepository>()), permanent: true);
    Get.put(GetSchedulesByDay(Get.find<PatientScheduleRepository>()), permanent: true);
    Get.put(SearchSchedules(Get.find<PatientScheduleRepository>()), permanent: true);

    // Controller Layer
    Get.put(
      PatientController(
        getAllSchedules: Get.find(),
        getSchedulesByDay: Get.find(),
        searchSchedules: Get.find(),
      ),
      permanent: true,
    );
  }
}
