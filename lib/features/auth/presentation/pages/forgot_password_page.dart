import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final emailController = TextEditingController();
    
    // Get screen size
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isVerySmallScreen = size.height < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => Get.back(),
        ),
      ),
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
                      title: "Lupa Password?",
                      subtitle: "Masukkan email Anda dan kami akan mengirimkan link untuk reset password",
                      icon: Icons.lock_reset_rounded,
                      isSmallScreen: isSmallScreen,
                      isVerySmallScreen: isVerySmallScreen,
                    ),

                    SizedBox(height: isVerySmallScreen ? 24 : (isSmallScreen ? 28 : 32)),

                    // Info Box
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF3B82F6),
                            size: isSmallScreen ? 20 : 24,
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 12),
                          Expanded(
                            child: Text(
                              'Link reset password akan dikirim ke email @pens.ac.id Anda',
                              style: TextStyle(
                                color: const Color(0xFF1E40AF),
                                fontSize: isSmallScreen ? 12 : 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 28)),

                    // Form
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

                          SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),

                          // Send Reset Link Button
                          Obx(() {
                            return CustomButton(
                              text: "Kirim Link Reset",
                              icon: Icons.send_rounded,
                              isLoading: controller.isLoading.value,
                              isSmallScreen: isSmallScreen,
                              onPressed: () {
                                if (_validateForm(emailController)) {
                                  controller.forgotPassword(
                                    emailController.text.trim(),
                                  );
                                }
                              },
                            );
                          }),

                          // Back to Login
                          CustomButton(
                            text: "Kembali ke Login",
                            isOutlined: true,
                            icon: Icons.arrow_back_rounded,
                            isSmallScreen: isSmallScreen,
                            onPressed: () => Get.back(),
                          ),
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

  bool _validateForm(TextEditingController email) {
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
    if (!email.text.endsWith('@pens.ac.id')) {
      Get.snackbar(
        "Error",
        "Email harus menggunakan domain @pens.ac.id",
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
