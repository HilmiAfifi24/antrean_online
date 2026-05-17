import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/queue_remote_datasource.dart';
import '../../data/repositories/patient_queue_repository_impl.dart';
import '../../domain/repositories/patient_queue_repository.dart';
import '../../domain/usecases/get_active_queue.dart';
import '../../domain/usecases/create_queue.dart';
import '../../domain/usecases/cancel_queue.dart';
import '../../domain/usecases/get_available_reschedule_dates.dart';
import '../../domain/usecases/reschedule_queue.dart';
import '../../domain/usecases/validate_reschedule_eligibility.dart';
import '../controllers/queue_controller.dart';

class QueueBinding extends Bindings {
  @override
  dependencies() {
    // Data Source
    Get.put<QueueRemoteDataSource>(
      QueueRemoteDataSource(FirebaseFirestore.instance),
      permanent: true,
    );

    // Repository
    Get.put<PatientQueueRepository>(
      PatientQueueRepositoryImpl(Get.find<QueueRemoteDataSource>()),
      permanent: true,
    );

    // Use Cases
    Get.put(GetActiveQueue(Get.find()), permanent: true);
    Get.put(CreateQueue(Get.find()), permanent: true);
    Get.put(CancelQueue(Get.find()), permanent: true);
    Get.put(ValidateRescheduleEligibility(Get.find()), permanent: true);
    Get.put(GetAvailableRescheduleDates(Get.find()), permanent: true);
    Get.put(RescheduleQueue(Get.find()), permanent: true);

    // Controller
    Get.put(
      QueueController(repository: Get.find<PatientQueueRepository>()),
      permanent: true,
    );
  }
}
