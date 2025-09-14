import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:antrean_online/features/admin/home/data/datasources/admin_remote_data_source.dart';
import 'package:antrean_online/features/admin/home/data/repositories/admin_repository_impl.dart';
import 'package:antrean_online/features/admin/home/domain/repositories/admin_repository.dart';
import 'package:antrean_online/features/admin/home/domain/usecases/get_dashboard_stats.dart';
import 'package:antrean_online/features/admin/home/domain/usecases/get_recent_activities.dart';
import 'package:antrean_online/features/admin/home/presentation/controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // Data Layer
    Get.lazyPut<AdminRemoteDataSource>(
      () => AdminRemoteDataSource(Get.find<FirebaseFirestore>()),
    );

    // Repository Layer
    Get.lazyPut<AdminRepository>(
      () => AdminRepositoryImpl(Get.find<AdminRemoteDataSource>()),
    );

    // Use Cases Layer
    Get.lazyPut(() => GetDashboardStats(Get.find<AdminRepository>()));
    Get.lazyPut(() => GetRecentActivities(Get.find<AdminRepository>()));

    // Controller Layer
    Get.put(AdminController(
          getDashboardStats: Get.find(),
          getRecentActivities: Get.find(),
        ));
  }
}
