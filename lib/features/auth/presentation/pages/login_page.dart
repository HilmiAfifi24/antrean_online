// pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final emailController = controller.emailController;
    final passwordController = controller.passwordController;
    final rememberMe = controller.rememberMe;
    final role = Get.parameters['role'] ?? 'patient';
    
    // Mendapatkan ukuran layar
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isVerySmallScreen = size.height < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : size.width * 0.06),
                vertical: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (isVerySmallScreen ? 24 : (isSmallScreen ? 32 : 48)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 20)),

                    // Header
                    AuthHeader(
                      title: "Selamat Datang",
                      subtitle: "Masuk ke akun Anda untuk mengakses layanan kesehatan terbaik klinik PENS",
                      icon: Icons.local_hospital_rounded,
                      isSmallScreen: isSmallScreen,
                      isVerySmallScreen: isVerySmallScreen,
                    ),

                    // Form Card
                    Form(
                      child: Column(
                        children: [
                          CustomInputField(
                            label: "Email",
                            hint: "Masukkan alamat email Anda",
                            controller: emailController,
                            prefixIcon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            isSmallScreen: isSmallScreen,
                          ),

                          CustomInputField(
                            label: "Password",
                            hint: "Masukkan password Anda",
                            controller: passwordController,
                            prefixIcon: Icons.lock_rounded,
                            obscureText: true,
                            isSmallScreen: isSmallScreen,
                          ),

                          // Remember Me & Forgot Password
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isVerySmallScreen ? 4 : 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() {
                                  return Row(
                                    children: [
                                      Transform.scale(
                                        scale: isSmallScreen ? 0.9 : 1.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Checkbox(
                                            value: rememberMe.value,
                                            onChanged: (value) {
                                              rememberMe.value = value ?? false;
                                            },
                                            activeColor: const Color(0xFF3B82F6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Ingat saya",
                                        style: TextStyle(
                                          color: const Color(0xFF64748B),
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                TextButton(
                                  onPressed: () {
                                    Get.snackbar(
                                      "Info",
                                      "Fitur lupa password akan segera tersedia",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFF3B82F6),
                                      colorText: Colors.white,
                                      borderRadius: 12,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 8 : 12,
                                      vertical: isSmallScreen ? 4 : 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Lupa Password?",
                                    style: TextStyle(
                                      color: const Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),

                          // Login Button
                          Obx(() {
                            return CustomButton(
                              text: "Masuk",
                              icon: Icons.login_rounded,
                              isLoading: controller.isLoading.value,
                              isSmallScreen: isSmallScreen,
                              onPressed: () {
                                if (_validateForm(
                                  emailController,
                                  passwordController,
                                )) {
                                  controller.login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                }
                              },
                            );
                          }),

                          // Register Link
                          if (role != 'admin' && role != 'doctor') ...[
                            CustomButton(
                              text: isSmallScreen 
                                  ? "Belum punya akun? Daftar" 
                                  : "Belum punya akun? Daftar di sini",
                              isOutlined: true,
                              icon: Icons.person_add_rounded,
                              isSmallScreen: isSmallScreen,
                              onPressed: () => Get.toNamed("/register"),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 24 : 48)),

                    // Footer
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Klinik PENS - Layanan Kesehatan Terpercaya",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _validateForm(
    TextEditingController email,
    TextEditingController password,
  ) {
    if (email.text.trim().isEmpty || !email.text.contains('@')) {
      Get.snackbar(
        "Error",
        "Email tidak valid",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        borderRadius: 12,
      );
      return false;
    }
    if (password.text.length < 6) {
      Get.snackbar(
        "Error",
        "Password minimal 6 karakter",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        borderRadius: 12,
      );
      return false;
    }
    return true;
  }
}