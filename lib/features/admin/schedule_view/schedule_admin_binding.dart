import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:antrean_online/features/admin/schedule_view/data/datasources/schedule_admin_remote_datsource.dart';
import 'package:antrean_online/features/admin/schedule_view/data/repositories/schedule_admin_repository_impl.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_all_schedules.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_schedule_by_id.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/add_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/update_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/delete_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/activate_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/search_schedules.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_schedules_by_doctor.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/controllers/schedule_admin_controller.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/get_all_doctors.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure Firebase instances are available
    if (!Get.isRegistered<FirebaseFirestore>()) {
      Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);
    }
    if (!Get.isRegistered<FirebaseAuth>()) {
      Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    }

    // Data Layer
    Get.put<ScheduleAdminRemoteDatasource>(
      ScheduleAdminRemoteDatasource(
        firestore: Get.find<FirebaseFirestore>(),
        auth: Get.find<FirebaseAuth>(),
      ),
      permanent: true,
    );

    // Repository Layer
    Get.put<ScheduleAdminRepository>(
      ScheduleAdminRepositoryImpl(Get.find<ScheduleAdminRemoteDatasource>()),
      permanent: true,
    );

    // Use Cases Layer
    Get.put(GetAllSchedules(Get.find<ScheduleAdminRepository>()), permanent: true);
    Get.put(GetScheduleById(Get.find<ScheduleAdminRepository>()), permanent: true);
    Get.put(AddSchedule(Get.find<ScheduleAdminRepository>()), permanent: true);
    Get.put(UpdateSchedule(Get.find<ScheduleAdminRepository>()), permanent: true);
    Get.put(DeleteSchedule(Get.find<ScheduleAdminRepository>()), permanent: true);
    Get.put(ActivateSchedule(Get.find<ScheduleAdminRepository>()), permanent: true);
    Get.put(SearchSchedules(Get.find<ScheduleAdminRepository>()), permanent: true);
    Get.put(GetSchedulesByDoctor(Get.find<ScheduleAdminRepository>()), permanent: true);

    // Doctor use case (reuse from existing binding)
    if (!Get.isRegistered<GetAllDoctors>()) {
      Get.put(GetAllDoctors(Get.find()), permanent: true);
    }

    // Controller Layer
    Get.put(
      ScheduleController(
        getAllSchedules: Get.find(),
        getScheduleById: Get.find(),
        addSchedule: Get.find(),
        updateSchedule: Get.find(),
        deleteSchedule: Get.find(),
        activateSchedule: Get.find(),
        searchSchedules: Get.find(),
        getSchedulesByDoctor: Get.find(),
        getAllDoctors: Get.find(),
      ),
      permanent: true,
    );
  }
}
