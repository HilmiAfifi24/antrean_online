import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:antrean_online/features/admin/home/data/datasources/admin_remote_data_source.dart';
import 'package:antrean_online/features/admin/home/data/repositories/admin_repository_impl.dart';
import 'package:antrean_online/features/admin/home/domain/repositories/admin_repository.dart';
import 'package:antrean_online/features/admin/home/domain/usecases/get_dashboard_stats.dart';
import 'package:antrean_online/features/admin/home/domain/usecases/get_recent_activities.dart';
import 'package:antrean_online/features/admin/home/presentation/controllers/admin_controller.dart';
import 'package:antrean_online/features/auth/auth_binding.dart';
import 'package:antrean_online/features/auth/presentation/controllers/auth_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure Firebase instances are available
    if (!Get.isRegistered<FirebaseFirestore>()) {
      Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);
    }
    if (!Get.isRegistered<FirebaseAuth>()) {
      Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    }

    // Initialize Auth dependencies if not already available
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }

    // Data Layer
    if (!Get.isRegistered<AdminRemoteDataSource>()) {
      Get.put<AdminRemoteDataSource>(
        AdminRemoteDataSource(Get.find<FirebaseFirestore>()),
        permanent: true,
      );
    }

    // Repository Layer
    if (!Get.isRegistered<AdminRepository>()) {
      Get.put<AdminRepository>(
        AdminRepositoryImpl(Get.find<AdminRemoteDataSource>()),
        permanent: true,
      );
    }

    // Use Cases Layer
    if (!Get.isRegistered<GetDashboardStats>()) {
      Get.put(GetDashboardStats(Get.find<AdminRepository>()), permanent: true);
    }
    if (!Get.isRegistered<GetRecentActivities>()) {
      Get.put(GetRecentActivities(Get.find<AdminRepository>()), permanent: true);
    }

    // Controller Layer
    if (!Get.isRegistered<AdminController>()) {
      Get.put(AdminController(
        getDashboardStats: Get.find(),
        getRecentActivities: Get.find(),
      ), permanent: true);
    }
  }
}
