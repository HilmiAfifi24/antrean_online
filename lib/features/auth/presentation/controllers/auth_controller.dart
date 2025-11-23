import 'package:flutter/material.dart';
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

  Future<void> login(String email, String password, {String? expectedRole}) async {

    if(!email.endsWith("@pens.ac.id")) {
      Get.snackbar(
        "Error", 
        "Email harus menggunakan domain @pens.ac.id",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }
    try {
      isLoading.value = true;
      final user = await loginUser(email, password);
      currentUser.value = user;

      // Validate role if expectedRole is provided
      if (expectedRole != null && user.role != expectedRole) {
        await registerUser.repository.logout(); // Logout immediately
        Get.snackbar(
          "Akses Ditolak",
          "Anda tidak memiliki akses sebagai ${_getRoleDisplayName(expectedRole)}. Role Anda: ${_getRoleDisplayName(user.role)}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // Navigate based on user role
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

  // Helper method to get display name for role
  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'dokter':
        return 'Dokter';
      case 'pasien':
        return 'Pasien';
      default:
        return role;
    }
  }

  Future<void> register(String email, String password, String role, String name) async {

    if (!email.endsWith("@pens.ac.id")) {
      Get.snackbar("Error", "Email must be a valid pens.ac.id address");
      return;
    }
    try {
      isLoading.value = true;
      final user = await registerUser(email, password, role, name);
      currentUser.value = user;
      
      Get.snackbar(
        "Sukses",
        "Registrasi berhasil! Silakan login dengan akun Anda",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      
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
