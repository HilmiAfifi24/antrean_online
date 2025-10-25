import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth_header.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final nameController = TextEditingController();
    final role = "pasien".obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const AuthHeader(
                title: "Daftar Akun",
                subtitle: "Buat akun baru untuk mengakses layanan medis",
                icon: Icons.person_add,
              ),

              // Form
              Form(
                child: Column(
                  children: [
                    CustomInputField(
                      label: "Nama Lengkap",
                      hint: "Masukkan nama lengkap Anda",
                      controller: nameController,
                      prefixIcon: Icons.person,
                      keyboardType: TextInputType.name,
                    ),
                    
                    CustomInputField(
                      label: "Email",
                      hint: "Masukkan alamat email Anda",
                      controller: emailController,
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    CustomInputField(
                      label: "Password",
                      hint: "Masukkan password Anda",
                      controller: passwordController,
                      prefixIcon: Icons.lock,
                      obscureText: true,
                    ),

                    CustomInputField(
                      label: "Konfirmasi Password",
                      hint: "Masukkan ulang password Anda",
                      controller: confirmPasswordController,
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                    ),

                    CustomDropdown(
                      label: "Pilih Peran",
                      selectedValue: role,
                      items: const ["admin", "dokter", "pasien"],
                      onChanged: (val) {
                        if (val != null) {
                          role.value = val;
                        }
                      },
                    ),

                    const SizedBox(height: 8),

                    // Register Button
                    Obx(() {
                      return CustomButton(
                        text: "Daftar Sekarang",
                        icon: Icons.person_add,
                        isLoading: controller.isLoading.value,
                        onPressed: () {
                          if (_validateForm(emailController, passwordController, 
                              confirmPasswordController, nameController)) {
                            controller.register(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              role.value,
                              nameController.text.trim(),
                            );
                          }
                        },
                      );
                    }),

                    // Login Link
                    CustomButton(
                      text: "Sudah punya akun? Masuk di sini",
                      isOutlined: true,
                      icon: Icons.login,
                      // textColor: Colors.grey[700],
                      onPressed: () => Get.toNamed("/login"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Terms and Conditions
              Text(
                "Dengan mendaftar, Anda menyetujui Syarat & Ketentuan dan Kebijakan Privasi kami.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
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
    TextEditingController confirmPassword,
    TextEditingController name,
  ) {
    if (name.text.trim().isEmpty) {
      Get.snackbar("Error", "Nama tidak boleh kosong");
      return false;
    }
    if (email.text.trim().isEmpty || !email.text.contains('@')) {
      Get.snackbar("Error", "Email tidak valid");
      return false;
    }
    if (password.text.length < 6) {
      Get.snackbar("Error", "Password minimal 6 karakter");
      return false;
    }
    if (password.text != confirmPassword.text) {
      Get.snackbar("Error", "Password tidak cocok");
      return false;
    }
    return true;
  }
}