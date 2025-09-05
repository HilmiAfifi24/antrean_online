import 'package:antrean_online/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'domain/usecases/login_user.dart';
import 'domain/usecases/register_user.dart';
import 'presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final remoteDataSource =
        AuthRemoteDataSource(FirebaseAuth.instance, FirebaseFirestore.instance);

    final repository = AuthRepositoryImpl(remoteDataSource);

    Get.lazyPut(() => LoginUser(repository));
    Get.lazyPut(() => RegisterUser(repository));

    Get.put(AuthController(
      loginUser: Get.find(),
      registerUser: Get.find(),
    ));
  }
}
