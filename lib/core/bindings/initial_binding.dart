import 'package:antrean_online/features/admin/home/data/repositories/admin_repository_impl.dart';
import 'package:antrean_online/features/admin/home/domain/usecases/get_dashboard_stats.dart';
import 'package:antrean_online/features/admin/home/domain/usecases/get_recent_activities.dart';
import 'package:antrean_online/features/admin/home/presentation/controllers/admin_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:antrean_online/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:antrean_online/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:antrean_online/features/auth/domain/usecases/login_user.dart';
import 'package:antrean_online/features/auth/domain/usecases/register_user.dart';
import 'package:antrean_online/features/auth/presentation/controllers/auth_controller.dart';

import '../../features/admin/home/data/datasources/admin_remote_data_source.dart'
    show AdminRemoteDataSource;

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Firebase instances
    Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);

    // Auth dependencies
    final remoteDataSource = AuthRemoteDataSource(
      Get.find<FirebaseAuth>(),
      Get.find<FirebaseFirestore>(),
    );

    final repository = AuthRepositoryImpl(remoteDataSource);

    Get.lazyPut(() => LoginUser(repository));
    Get.lazyPut(() => RegisterUser(repository));

    Get.put(
      AuthController(loginUser: Get.find(), registerUser: Get.find()),
      permanent: true,
    );

    // admin dependencies
    final adminRemoteDataSource = AdminRemoteDataSource(
      Get.find<FirebaseFirestore>(),
    );

    final adminRepository = AdminRepositoryImpl(adminRemoteDataSource);

    Get.lazyPut(() => GetDashboardStats(adminRepository));
    Get.lazyPut(() => GetRecentActivities(adminRepository));

    Get.put(
      AdminController(
        getDashboardStats: Get.find(),
        getRecentActivities: Get.find(),
      ),
      permanent: true,
    );
  }
}
