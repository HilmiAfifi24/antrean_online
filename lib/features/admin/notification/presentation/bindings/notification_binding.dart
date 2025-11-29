import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/config/fonnte_config.dart';
import '../controllers/notification_controller.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/usecases/send_queue_opened_notifications.dart';
import '../../domain/usecases/send_practice_started_notifications.dart';
import '../../domain/usecases/process_pending_notifications.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // Remote Data Source
    Get.lazyPut<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(
        fonnteApiToken: FonnteConfig.apiToken,
        fonnteBaseUrl: FonnteConfig.baseUrl,
        client: http.Client(),
        firestore: FirebaseFirestore.instance,
      ),
    );

    // Repository
    Get.lazyPut<NotificationRepositoryImpl>(
      () => NotificationRepositoryImpl(
        remoteDataSource: Get.find(),
        firestore: FirebaseFirestore.instance,
      ),
    );

    // Use Cases
    Get.lazyPut(() => SendQueueOpenedNotifications(Get.find<NotificationRepositoryImpl>()));
    Get.lazyPut(() => SendPracticeStartedNotifications(Get.find<NotificationRepositoryImpl>()));
    Get.lazyPut(() => ProcessPendingNotifications(Get.find<NotificationRepositoryImpl>()));

    // Controller
    Get.lazyPut<NotificationController>(
      () => NotificationController(
        sendQueueOpenedNotifications: Get.find(),
        sendPracticeStartedNotifications: Get.find(),
        processPendingNotifications: Get.find(),
      ),
    );
  }
}
