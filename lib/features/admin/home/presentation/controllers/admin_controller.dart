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

  StreamSubscription? _doctorsSubscription;
  StreamSubscription? _schedulesSubscription;
  StreamSubscription? _patientsSubscription;
  StreamSubscription? _queuesSubscription;
  StreamSubscription? _activitiesSubscription;
  Timer? _timestampUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadRecentActivities();
    _setupRealtimeListener();
    _setupTimestampUpdateTimer();
  }

  // Setup timer untuk update timestamp setiap menit
  void _setupTimestampUpdateTimer() {
    // Update timestamp setiap 60 detik (1 menit)
    _timestampUpdateTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // Update observable untuk trigger UI rebuild dengan timestamp baru
      recentActivities.refresh();
    });
  }

  void _setupRealtimeListener() {
    // Cancel existing subscriptions
    _doctorsSubscription?.cancel();
    _schedulesSubscription?.cancel();
    _patientsSubscription?.cancel();
    _queuesSubscription?.cancel();
    _activitiesSubscription?.cancel();

    // Listen to doctors collection
    _doctorsSubscription = FirebaseFirestore.instance
        .collection('doctors')
        .snapshots()
        .listen((snapshot) {
      loadDashboardData();
    });

    // Listen to schedules collection untuk auto-update total jadwal
    _schedulesSubscription = FirebaseFirestore.instance
        .collection('schedules')
        .snapshots()
        .listen((snapshot) {
      loadDashboardData();
    });

    // Listen to users collection untuk auto-update total pasien
    _patientsSubscription = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'pasien')
        .snapshots()
        .listen((snapshot) {
      loadDashboardData();
    });

    // Listen to queues collection untuk auto-update total antrean
    _queuesSubscription = FirebaseFirestore.instance
        .collection('queues')
        .snapshots()
        .listen((snapshot) {
      loadDashboardData();
    });

    // Listen to activities collection untuk auto-update riwayat aktivitas
    _activitiesSubscription = FirebaseFirestore.instance
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) {
      loadRecentActivities(); // Reload activities saat ada perubahan
    });
  }

  @override
  void onClose() {
    // Cancel all subscriptions
    _doctorsSubscription?.cancel();
    _schedulesSubscription?.cancel();
    _patientsSubscription?.cancel();
    _queuesSubscription?.cancel();
    _activitiesSubscription?.cancel();
    
    // Cancel timestamp update timer
    _timestampUpdateTimer?.cancel();
    
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

  // Format timestamp untuk display (dipanggil setiap UI rebuild)
  String formatActivityTime(dynamic timestamp) {
    if (timestamp == null) return 'Baru saja';
    
    DateTime time;
    if (timestamp is Timestamp) {
      time = timestamp.toDate();
    } else if (timestamp is DateTime) {
      time = timestamp;
    } else {
      return 'Baru saja';
    }

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${difference.inDays} hari lalu';
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