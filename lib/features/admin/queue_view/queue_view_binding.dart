import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/datasources/queue_admin_remote_datasource.dart';
import 'data/repositories/queue_admin_repository_impl.dart';
import 'domain/repositories/queue_admin_repository.dart';
import 'domain/usecases/get_today_queues.dart';
import 'presentation/controllers/queue_view_controller.dart';

class QueueViewBinding extends Bindings {
  @override
  void dependencies() {
    // Firestore instance (reuse if already registered)
    if (!Get.isRegistered<FirebaseFirestore>()) {
      Get.put(FirebaseFirestore.instance, permanent: true);
    }

    // Data Source
    Get.lazyPut<QueueAdminRemoteDataSource>(
      () => QueueAdminRemoteDataSource(Get.find<FirebaseFirestore>()),
    );

    // Repository
    Get.lazyPut<QueueAdminRepository>(
      () => QueueAdminRepositoryImpl(Get.find<QueueAdminRemoteDataSource>()),
    );

    // Use Cases
    Get.lazyPut(() => GetQueuesByDate(Get.find<QueueAdminRepository>()));

    // Controller
    Get.lazyPut(
      () => QueueViewController(
        getQueuesByDate: Get.find<GetQueuesByDate>(),
      ),
    );
  }
}
