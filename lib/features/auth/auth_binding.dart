import 'package:get/get.dart';
import 'package:antrean_online/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:antrean_online/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:antrean_online/features/auth/domain/usecases/login_user.dart';
import 'package:antrean_online/features/auth/domain/usecases/register_user.dart';
import 'package:antrean_online/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final remoteDataSource = AuthRemoteDataSource(
      Get.find<FirebaseAuth>(),
      Get.find<FirebaseFirestore>(),
    );

    final repository = AuthRepositoryImpl(remoteDataSource);

    Get.lazyPut(() => LoginUser(repository));
    Get.lazyPut(() => RegisterUser(repository));

    Get.put(AuthController(
      loginUser: Get.find(),
      registerUser: Get.find(),
    ));
  }
}
