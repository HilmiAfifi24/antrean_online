import 'package:get/get.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/usecases/get_recent_activities.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends GetxController {
  final GetDashboardStats getDashboardStats;
  final GetRecentActivities getRecentActivities;

  AdminController({
    required this.getDashboardStats,
    required this.getRecentActivities,
  });

  // Observable variables
  var totalPasien = 0.obs;
  var totalDokter = 0.obs;
  var totalJadwal = 0.obs;
  var totalAntrean = 0.obs;
  
  var isLoading = false.obs;
  var recentActivities = <Map<String, dynamic>>[].obs;

  StreamSubscription? _statsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadRecentActivities();
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    _statsSubscription?.cancel();
    _statsSubscription = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'dokter')
        .snapshots()
        .listen((snapshot) {
      loadDashboardData();
    });
  }

  @override
  void onClose() {
    _statsSubscription?.cancel();
    super.onClose();
  }

  // Load dashboard statistics from Firebase
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      
      final stats = await getDashboardStats();
      
      totalPasien.value = stats['totalPasien'] ?? 0;
      totalDokter.value = stats['totalDokter'] ?? 0;
      totalJadwal.value = stats['totalJadwal'] ?? 0;
      totalAntrean.value = stats['totalAntrean'] ?? 0;
      
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memuat data dashboard: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load recent activities from Firebase
  Future<void> loadRecentActivities() async {
    try {
      final activities = await getRecentActivities();
      recentActivities.value = activities;
    } catch (e) {
      // Handle error silently for activities
      recentActivities.value = [];
    }
  }

  // Refresh all data
  Future<void> refreshDashboard() async {
    await Future.wait([
      loadDashboardData(),
      loadRecentActivities(),
    ]);
  }

  // Navigation methods
  void navigateToPatients() => Get.toNamed("/admin/patients");
  void navigateToDoctors() => Get.toNamed("/admin/doctors");
  void navigateToSchedules() => Get.toNamed("/admin/schedules");
  void navigateToQueues() => Get.toNamed("/admin/queues");
  void navigateToReports() => Get.toNamed("/admin/reports");
  void navigateToSettings() => Get.toNamed("/admin/settings");
}