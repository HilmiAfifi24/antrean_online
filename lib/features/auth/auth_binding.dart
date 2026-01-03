import 'package:get/get.dart';
import 'package:antrean_online/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:antrean_online/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:antrean_online/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:antrean_online/features/auth/domain/usecases/login_user.dart';
import 'package:antrean_online/features/auth/domain/usecases/register_user.dart';
import 'package:antrean_online/features/auth/domain/usecases/save_credentials.dart';
import 'package:antrean_online/features/auth/domain/usecases/get_saved_credentials.dart';
import 'package:antrean_online/features/auth/domain/usecases/clear_saved_credentials.dart';
import 'package:antrean_online/features/auth/domain/usecases/has_remembered_credentials.dart';
import 'package:antrean_online/features/auth/domain/usecases/reset_password.dart';
import 'package:antrean_online/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // SharedPreferences, FirebaseAuth, and FirebaseFirestore 
    // already initialized in main() before app starts
    
    // Remote data source
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSource(
      Get.find<FirebaseAuth>(),
      Get.find<FirebaseFirestore>(),
    ));

    // Local data source
    Get.lazyPut<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(
      Get.find<SharedPreferences>(),
    ));

    // Repository
    Get.lazyPut<AuthRepositoryImpl>(() => AuthRepositoryImpl(
      Get.find<AuthRemoteDataSource>(),
      Get.find<AuthLocalDataSource>(),
    ));

    // Use cases
    Get.lazyPut(() => LoginUser(Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => RegisterUser(Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => SaveCredentials(Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => GetSavedCredentials(Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => ClearSavedCredentials(Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => HasRememberedCredentials(Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => ResetPassword(Get.find<AuthRepositoryImpl>()));

    // Controller - Make it permanent so it persists across different bindings
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
}
