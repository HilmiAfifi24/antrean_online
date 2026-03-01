import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:antrean_online/features/admin/schedule_view/data/datasources/schedule_admin_remote_datsource.dart';
import 'package:antrean_online/features/admin/schedule_view/data/repositories/schedule_admin_repository_impl.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/repositories/schedule_admin_repository.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_all_schedules.dart'
    as schedule_admin_usecases;
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_schedule_by_id.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/add_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/update_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/delete_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/activate_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/search_schedules.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_schedules_by_doctor.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/controllers/schedule_admin_controller.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/get_all_doctors.dart';
import 'package:antrean_online/features/admin/doctor_view/data/datasources/doctor_admin_remote_datasource.dart';
import 'package:antrean_online/features/admin/doctor_view/data/repositories/doctor_admin_repository_impl.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';
import 'package:antrean_online/features/admin/notification/presentation/controllers/notification_controller.dart';
import 'package:antrean_online/core/config/fonnte_config.dart';
import 'package:antrean_online/features/admin/notification/data/datasources/notification_remote_datasource.dart';
import 'package:antrean_online/features/admin/notification/data/repositories/notification_repository_impl.dart';
import 'package:antrean_online/features/admin/notification/domain/usecases/send_queue_opened_notifications.dart';
import 'package:antrean_online/features/admin/notification/domain/usecases/send_practice_started_notifications.dart';
import 'package:antrean_online/features/admin/notification/domain/usecases/process_pending_notifications.dart';
import 'package:http/io_client.dart';
import 'dart:io';

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

    // Data Layer - Schedule
    Get.put<ScheduleAdminRemoteDatasource>(
      ScheduleAdminRemoteDatasource(
        firestore: Get.find<FirebaseFirestore>(),
        auth: Get.find<FirebaseAuth>(),
      ),
      permanent: true,
    );

    // Data Layer - Doctor (needed for schedule controller)
    if (!Get.isRegistered<DoctorAdminRemoteDatasource>()) {
      Get.put<DoctorAdminRemoteDatasource>(
        DoctorAdminRemoteDatasource(
          firestore: Get.find<FirebaseFirestore>(),
          auth: Get.find<FirebaseAuth>(),
        ),
        permanent: true,
      );
    }

    // Repository Layer - Schedule
    Get.put<ScheduleAdminRepository>(
      ScheduleAdminRepositoryImpl(Get.find<ScheduleAdminRemoteDatasource>()),
      permanent: true,
    );

    // Repository Layer - Doctor (needed for GetAllDoctors use case)
    if (!Get.isRegistered<DoctorAdminRepository>()) {
      Get.put<DoctorAdminRepository>(
        DoctorAdminRepositoryImpl(Get.find<DoctorAdminRemoteDatasource>()),
        permanent: true,
      );
    }

    // Use Cases Layer - Schedule
    Get.put(
      schedule_admin_usecases.GetAllSchedules(
        Get.find<ScheduleAdminRepository>(),
      ),
      permanent: true,
    );
    Get.put(
      GetScheduleById(Get.find<ScheduleAdminRepository>()),
      permanent: true,
    );
    Get.put(AddSchedule(Get.find<ScheduleAdminRepository>()), permanent: true);
    Get.put(
      UpdateSchedule(Get.find<ScheduleAdminRepository>()),
      permanent: true,
    );
    Get.put(
      DeleteSchedule(Get.find<ScheduleAdminRepository>()),
      permanent: true,
    );
    Get.put(
      ActivateSchedule(Get.find<ScheduleAdminRepository>()),
      permanent: true,
    );
    Get.put(
      SearchSchedules(Get.find<ScheduleAdminRepository>()),
      permanent: true,
    );
    Get.put(
      GetSchedulesByDoctor(Get.find<ScheduleAdminRepository>()),
      permanent: true,
    );

    // Use Cases Layer - Doctor (needed for schedule controller)
    if (!Get.isRegistered<GetAllDoctors>()) {
      Get.put(
        GetAllDoctors(Get.find<DoctorAdminRepository>()),
        permanent: true,
      );
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

    // Initialize Notification services directly to avoid 'not found' errors in dialogs
    Get.put<NotificationController>(
      NotificationController(
        sendQueueOpenedNotifications: Get.put(
          SendQueueOpenedNotifications(
            Get.put(
              NotificationRepositoryImpl(
                remoteDataSource: Get.put(
                  NotificationRemoteDataSourceImpl(
                    fonnteApiToken: FonnteConfig.apiToken,
                    fonnteBaseUrl: FonnteConfig.baseUrl,
                    client: IOClient(
                      HttpClient()
                        ..connectionTimeout = const Duration(seconds: 30)
                        ..badCertificateCallback =
                            (X509Certificate cert, String host, int port) =>
                                host == 'api.fonnte.com',
                    ),
                    firestore: FirebaseFirestore.instance,
                  ),
                ),
                firestore: FirebaseFirestore.instance,
              ),
            ),
          ),
        ),
        sendPracticeStartedNotifications: Get.put(
          SendPracticeStartedNotifications(
            Get.find<NotificationRepositoryImpl>(),
          ),
        ),
        processPendingNotifications: Get.put(
          ProcessPendingNotifications(Get.find<NotificationRepositoryImpl>()),
        ),
      ),
      permanent: true,
    );
  }
}
