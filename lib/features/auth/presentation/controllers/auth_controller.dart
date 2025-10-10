import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/entities/user_entity.dart';

class AuthController extends GetxController {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthController({
    required this.loginUser,
    required this.registerUser,
  });

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberMe = false.obs;

  var isLoading = false.obs;
  var currentUser = Rxn<UserEntity>();

  Future<void> login(String email, String password) async {

    if(!email.endsWith("@pens.ac.id")) {
      Get.snackbar("Error", "Email must be a valid pens.ac.id address");
      return;
    }
    try {
      isLoading.value = true;
      final user = await loginUser(email, password);
      currentUser.value = user;

      if (user.role == "admin") {
        Get.offAllNamed("/admin");
      } else if (user.role == "dokter") {
        Get.offAllNamed("/dokter");
      } else {
        Get.offAllNamed("/pasien");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String role) async {

    if (!email.endsWith("@pens.ac.id")) {
      Get.snackbar("Error", "Email must be a valid pens.ac.id address");
      return;
    }
    try {
      isLoading.value = true;
      final user = await registerUser(email, password, role);
      currentUser.value = user;
      Get.offAllNamed("/login");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
  try {
    await registerUser.repository.logout(); 
    currentUser.value = null;
    Get.offAllNamed("/login");
  } catch (e) {
    Get.snackbar("Error", e.toString());
  }
}

}
