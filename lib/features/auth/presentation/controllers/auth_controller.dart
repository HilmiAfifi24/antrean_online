import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/save_credentials.dart';
import '../../domain/usecases/get_saved_credentials.dart';
import '../../domain/usecases/clear_saved_credentials.dart';
import '../../domain/usecases/has_remembered_credentials.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/entities/user_entity.dart';

class AuthController extends GetxController {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final SaveCredentials saveCredentials;
  final GetSavedCredentials getSavedCredentials;
  final ClearSavedCredentials clearSavedCredentials;
  final HasRememberedCredentials hasRememberedCredentials;
  final ResetPassword resetPassword;

  AuthController({
    required this.loginUser,
    required this.registerUser,
    required this.saveCredentials,
    required this.getSavedCredentials,
    required this.clearSavedCredentials,
    required this.hasRememberedCredentials,
    required this.resetPassword,
  });

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberMe = false.obs;

  var isLoading = false.obs;
  var currentUser = Rxn<UserEntity>();
  var isCheckingRememberedCredentials = true.obs;
  var hasLoginError = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  /// Load saved credentials if remember me was checked
  Future<void> _loadSavedCredentials() async {
    try {
      isCheckingRememberedCredentials.value = true;
      final hasRemembered = await hasRememberedCredentials();
      
      if (hasRemembered) {
        final credentials = await getSavedCredentials();
        if (credentials != null) {
          emailController.text = credentials['email'] ?? '';
          passwordController.text = credentials['password'] ?? '';
          rememberMe.value = true;
        }
      }
    } catch (e) {
      // Silently fail - user can still login manually
      debugPrint('Error loading saved credentials: $e');
    } finally {
      isCheckingRememberedCredentials.value = false;
    }
  }

  Future<void> login(String email, String password, {String? expectedRole}) async {
    if(!email.endsWith("@pens.ac.id")) {
      Get.snackbar(
        "Error", 
        "Email harus menggunakan domain @pens.ac.id",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
      return;
    }
    try {
      isLoading.value = true;
      hasLoginError.value = false;
      final user = await loginUser(email, password);
      currentUser.value = user;

      // Handle Remember Me
      if (rememberMe.value) {
        await saveCredentials(email, password);
      } else {
        await clearSavedCredentials();
      }

      // Validate role if expectedRole is provided
      if (expectedRole != null && user.role != expectedRole) {
        await registerUser.repository.logout(); // Logout immediately
        Get.snackbar(
          "Akses Ditolak",
          "Anda tidak memiliki akses sebagai ${_getRoleDisplayName(expectedRole)}. Role Anda: ${_getRoleDisplayName(user.role)}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          icon: const Icon(Icons.block, color: Colors.white),
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // Show success message
      Get.snackbar(
        "Berhasil",
        "Login berhasil! Selamat datang",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        duration: const Duration(seconds: 2),
      );

      // Navigate based on user role
      if (user.role == "admin") {
        Get.offAllNamed("/admin");
      } else if (user.role == "dokter") {
        Get.offAllNamed("/dokter");
      } else {
        Get.offAllNamed("/pasien");
      }
    } catch (e) {
      // Extract error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      hasLoginError.value = true;
      
      Get.snackbar(
        "Login Gagal",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        onTap: (_) {
          hasLoginError.value = false;
        },
      );
      
      // Auto enable button after error duration
      Future.delayed(const Duration(seconds: 5), () {
        hasLoginError.value = false;
      });
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

  Future<void> register(String email, String password, String role, String name, String phone) async {

    if (!email.endsWith("@pens.ac.id")) {
      Get.snackbar(
        "Error", 
        "Email harus menggunakan domain @pens.ac.id",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
      return;
    }
    try {
      isLoading.value = true;
      final user = await registerUser(email, password, role, name, phone);
      currentUser.value = user;
      
      Get.snackbar(
        "Sukses",
        "Registrasi berhasil! Silakan login dengan akun Anda",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
      
      Get.offAllNamed("/login");
    } catch (e) {
      // Extract error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      Get.snackbar(
        "Registrasi Gagal",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await registerUser.repository.logout(); 
      currentUser.value = null;
      
      // Clear form fields
      emailController.clear();
      passwordController.clear();
      rememberMe.value = false;
      
      Get.offAllNamed("/login");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      
      await resetPassword(email);
      
      Get.snackbar(
        "Berhasil",
        "Email reset password telah dikirim. Silakan cek inbox email Anda",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      Get.snackbar(
        "Gagal",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
