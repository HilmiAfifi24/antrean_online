import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/queue_remote_datasource.dart';
import '../../data/repositories/patient_queue_repository_impl.dart';
import '../../domain/repositories/patient_queue_repository.dart';
import '../../domain/usecases/get_active_queue.dart';
import '../../domain/usecases/create_queue.dart';
import '../../domain/usecases/cancel_queue.dart';
import '../controllers/queue_controller.dart';

class QueueBinding extends Bindings {
  @override
  dependencies() {
    // Data Source
    Get.lazyPut<QueueRemoteDataSource>(
      () => QueueRemoteDataSource(FirebaseFirestore.instance),
    );

    // Repository
    Get.lazyPut<PatientQueueRepository>(
      () => PatientQueueRepositoryImpl(
        Get.find<QueueRemoteDataSource>(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => GetActiveQueue(Get.find()));
    Get.lazyPut(() => CreateQueue(Get.find()));
    Get.lazyPut(() => CancelQueue(Get.find()));

    // Controller
    Get.lazyPut(
      () => QueueController(
        repository: Get.find<PatientQueueRepository>(),
      ),
    );
  }
}
