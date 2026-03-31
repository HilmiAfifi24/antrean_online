import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../data/datasources/queue_remote_datasource.dart';
import '../../data/repositories/patient_queue_repository_impl.dart';
import '../../domain/usecases/get_queue_history.dart';
import '../controllers/queue_history_controller.dart';

class QueueHistoryBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source & Repository
    final dataSource = QueueRemoteDataSource(FirebaseFirestore.instance);
    final repository = PatientQueueRepositoryImpl(dataSource);

    // Usecase
    final getQueueHistory = GetQueueHistory(repository);

    // Controller
    Get.lazyPut<QueueHistoryController>(
      () => QueueHistoryController(getQueueHistory: getQueueHistory),
    );
  }
}
