import 'package:flutter/material.dart';
import 'package:antrean_online/core/routes/app_routes.dart';
import 'package:antrean_online/features/auth/data/datasources/auth_storage_keys.dart';
import 'package:antrean_online/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminRouteMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final prefs = Get.isRegistered<SharedPreferences>()
        ? Get.find<SharedPreferences>()
        : null;
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;
    final currentRole = authController?.currentUser.value?.role ??
        prefs?.getString(AuthStorageKeys.currentUserRole);

    if (firebaseUser != null && currentRole == 'admin') {
      return null;
    }

    return const RouteSettings(
      name: AppRoutes.login,
      arguments: {'role': 'admin'},
    );
  }
}
