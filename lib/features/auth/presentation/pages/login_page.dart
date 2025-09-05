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
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final rememberMe = false.obs;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light blue-gray background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              const AuthHeader(
                title: "Selamat Datang",
                subtitle: "Masuk ke akun Anda untuk mengakses layanan kesehatan terbaik klinik PENS",
                icon: Icons.local_hospital_rounded,
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
                      ),

                      CustomInputField(
                        label: "Password",
                        hint: "Masukkan password Anda",
                        controller: passwordController,
                        prefixIcon: Icons.lock_rounded,
                        obscureText: true,
                      ),

                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() {
                            return Row(
                              children: [
                                Container(
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
                                  ),
                                ),
                                const Text(
                                  "Ingat saya",
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
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
                            child: const Text(
                              "Lupa Password?",
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Login Button
                      Obx(() {
                        return CustomButton(
                          text: "Masuk",
                          icon: Icons.login_rounded,
                          isLoading: controller.isLoading.value,
                          onPressed: () {
                            if (_validateForm(emailController, passwordController)) {
                              controller.login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            }
                          },
                        );
                      }),

                      // Register Link
                      CustomButton(
                        text: "Belum punya akun? Daftar di sini",
                        isOutlined: true,
                        icon: Icons.person_add_rounded,
                        onPressed: () => Get.toNamed("/register"),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 48),

              // Footer
              const Center(
                child: Text(
                  "Klinik PENS - Layanan Kesehatan Terpercaya",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
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