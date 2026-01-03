import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antrean_online/features/admin/home/data/datasources/admin_remote_data_source.dart';
import 'package:antrean_online/features/admin/home/data/repositories/admin_repository_impl.dart';
import 'package:antrean_online/features/admin/home/domain/repositories/admin_repository.dart';
import 'package:antrean_online/features/admin/home/domain/usecases/get_dashboard_stats.dart';
import 'package:antrean_online/features/admin/home/domain/usecases/get_recent_activities.dart';
import 'package:antrean_online/features/admin/home/presentation/controllers/admin_controller.dart';
import 'package:antrean_online/features/auth/presentation/controllers/auth_controller.dart';
import 'package:antrean_online/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:antrean_online/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:antrean_online/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:antrean_online/features/auth/domain/usecases/login_user.dart';
import 'package:antrean_online/features/auth/domain/usecases/register_user.dart';
import 'package:antrean_online/features/auth/domain/usecases/save_credentials.dart';
import 'package:antrean_online/features/auth/domain/usecases/get_saved_credentials.dart';
import 'package:antrean_online/features/auth/domain/usecases/clear_saved_credentials.dart';
import 'package:antrean_online/features/auth/domain/usecases/has_remembered_credentials.dart';
import 'package:antrean_online/features/auth/domain/usecases/reset_password.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FirebaseFirestore>()) {
      Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);
    }
    if (!Get.isRegistered<FirebaseAuth>()) {
      Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    }
    if (!Get.isRegistered<SharedPreferences>()) {
      Get.putAsync<SharedPreferences>(() async => await SharedPreferences.getInstance(), permanent: true);
    }

    // Ensure AuthController is registered
    if (!Get.isRegistered<AuthController>()) {
      // Register Auth dependencies
      if (!Get.isRegistered<AuthRemoteDataSource>()) {
        Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSource(
          Get.find<FirebaseAuth>(),
          Get.find<FirebaseFirestore>(),
        ), fenix: true);
      }

      if (!Get.isRegistered<AuthLocalDataSource>()) {
        Get.lazyPut<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(
          Get.find<SharedPreferences>(),
        ), fenix: true);
      }

      if (!Get.isRegistered<AuthRepositoryImpl>()) {
        Get.lazyPut<AuthRepositoryImpl>(() => AuthRepositoryImpl(
          Get.find<AuthRemoteDataSource>(),
          Get.find<AuthLocalDataSource>(),
        ), fenix: true);
      }

      // Register use cases
      if (!Get.isRegistered<LoginUser>()) {
        Get.lazyPut(() => LoginUser(Get.find<AuthRepositoryImpl>()), fenix: true);
      }
      if (!Get.isRegistered<RegisterUser>()) {
        Get.lazyPut(() => RegisterUser(Get.find<AuthRepositoryImpl>()), fenix: true);
      }
      if (!Get.isRegistered<SaveCredentials>()) {
        Get.lazyPut(() => SaveCredentials(Get.find<AuthRepositoryImpl>()), fenix: true);
      }
      if (!Get.isRegistered<GetSavedCredentials>()) {
        Get.lazyPut(() => GetSavedCredentials(Get.find<AuthRepositoryImpl>()), fenix: true);
      }
      if (!Get.isRegistered<ClearSavedCredentials>()) {
        Get.lazyPut(() => ClearSavedCredentials(Get.find<AuthRepositoryImpl>()), fenix: true);
      }
      if (!Get.isRegistered<HasRememberedCredentials>()) {
        Get.lazyPut(() => HasRememberedCredentials(Get.find<AuthRepositoryImpl>()), fenix: true);
      }
      if (!Get.isRegistered<ResetPassword>()) {
        Get.lazyPut(() => ResetPassword(Get.find<AuthRepositoryImpl>()), fenix: true);
      }

      // Register AuthController
      Get.put(AuthController(
        loginUser: Get.find(),
        registerUser: Get.find(),
        saveCredentials: Get.find(),
        getSavedCredentials: Get.find(),
        clearSavedCredentials: Get.find(),
        hasRememberedCredentials: Get.find(),
        resetPassword: Get.find(),
      ), permanent: true);
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
