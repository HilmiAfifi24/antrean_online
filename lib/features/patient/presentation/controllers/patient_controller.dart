import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/usecases/get_all_schedules.dart';
import '../../domain/usecases/get_schedules_by_day.dart';
import '../../domain/usecases/get_schedules_by_day_stream.dart';
import '../../domain/usecases/search_schedules.dart';

class PatientController extends GetxController {
  final GetAllSchedules getAllSchedules;
  final GetSchedulesByDay getSchedulesByDay;
  final GetSchedulesByDayStream getSchedulesByDayStream;
  final SearchSchedules searchSchedules;

  PatientController({
    required this.getAllSchedules,
    required this.getSchedulesByDay,
    required this.getSchedulesByDayStream,
    required this.searchSchedules,
  });

  // Observable variables
  final RxList<ScheduleEntity> _schedules = <ScheduleEntity>[].obs;
  final RxList<ScheduleEntity> _filteredSchedules = <ScheduleEntity>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedDay = ''.obs; // Will be set to today
  final RxString _patientName = ''.obs;
  final RxString _searchText = ''.obs;

  // Stream subscriptions
  StreamSubscription? _schedulesSubscription;
  StreamSubscription? _authStateSubscription;

  // Getters
  List<ScheduleEntity> get schedules => _schedules.toList();
  List<ScheduleEntity> get filteredSchedules => _filteredSchedules.toList();
  bool get isLoading => _isLoading.value;
  String get selectedDay => _selectedDay.value;
  String get patientName => _patientName.value;
  String get searchText => _searchText.value;

  // Greeting based on time
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  // Form controller
  final searchController = TextEditingController();

  // Available days
  final List<String> availableDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void onInit() {
    super.onInit();
    // Set selected day to today's day
    _selectedDay.value = _getTodayDayName();

    // Setup auth state listener to reload name when user changes
    _setupAuthStateListener();

    loadPatientName().then((_) {
      // Check if we need to prompt for name
      _checkAndPromptForName();
    });

    // Load schedules filtered by today's day
    filterByDay(_selectedDay.value);

    // Listen to search changes
    searchController.addListener(() {
      _searchText.value = searchController.text;
      if (searchController.text.isEmpty) {
        // When search cleared, reload with current day filter
        filterByDay(_selectedDay.value);
      } else {
        performSearch(searchController.text);
      }
    });
  }

  // Setup auth state listener
  void _setupAuthStateListener() {
    _authStateSubscription?.cancel();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) {
      if (user != null) {
        // User logged in or changed, reload name
        loadPatientName();
      } else {
        // User logged out
        _patientName.value = 'Pasien';
      }
    });
  }

  // Check if user needs to input their name
  Future<void> _checkAndPromptForName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          // If name field doesn't exist or empty, prompt user
          if (data?['name'] == null || data!['name'].toString().isEmpty) {
            _showNameInputDialog();
          }
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  // Show dialog to input name
  void _showNameInputDialog() {
    final nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Color(0xFF2196F3)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Lengkapi Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Silakan masukkan nama lengkap Anda untuk pengalaman yang lebih personal',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Contoh: Budi Santoso',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2196F3),
                    width: 2,
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Nanti', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Nama tidak boleh kosong',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade800,
                );
                return;
              }

              await _updateUserName(nameController.text.trim());
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Update user name in Firestore
  Future<void> _updateUserName(String name) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'name': name});

        _patientName.value = name;

        Get.snackbar(
          'Sukses',
          'Nama berhasil disimpan!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan nama: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  // Get today's day name in Indonesian
  String _getTodayDayName() {
    final now = DateTime.now();
    final dayIndex = now.weekday; // 1 = Monday, 7 = Sunday

    switch (dayIndex) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return 'Senin';
    }
  }

  @override
  void onClose() {
    _schedulesSubscription?.cancel();
    _authStateSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // Load patient name from Firebase Auth
  Future<void> loadPatientName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();

          // Try to get name from Firestore
          if (data?['name'] != null && data!['name'].toString().isNotEmpty) {
            _patientName.value = data['name'];
          } else {
            // Fallback: Extract name from email (before @)
            final email = user.email ?? '';
            if (email.isNotEmpty) {
              final username = email.split('@').first;
              // Capitalize first letter
              _patientName.value = username.isNotEmpty
                  ? username[0].toUpperCase() + username.substring(1)
                  : 'Pasien';
            } else {
              _patientName.value = 'Pasien';
            }
          }
        } else {
          _patientName.value = 'Pasien';
        }
      }
    } catch (e) {
      _patientName.value = 'Pasien';
    }
  }

  // Setup realtime listener for schedules with queue updates
  void _setupRealtimeListener() {
    _schedulesSubscription?.cancel();

    // Listen to schedules stream (filtered by selected day)
    if (_selectedDay.value.isNotEmpty) {
      _schedulesSubscription = getSchedulesByDayStream(_selectedDay.value)
          .listen(
            (schedules) {
              _schedules.value = schedules;

              // Apply current filter
              if (searchController.text.isNotEmpty) {
                performSearch(searchController.text);
              } else {
                _filteredSchedules.value = schedules;
              }
              _isLoading.value = false;
            },
            onError: (e) {
              _showError('Error loading schedules: $e');
              _isLoading.value = false;
            },
          );
    } else {
      _isLoading.value = false;
    }
  }

  // Load all schedules
  Future<void> loadSchedules() async {
    try {
      _isLoading.value = true;

      final result = await getAllSchedules();
      _schedules.value = result;

      // Apply filter based on selected day (today's day by default)
      if (_selectedDay.value.isNotEmpty) {
        filterByDay(_selectedDay.value);
      } else {
        _filteredSchedules.value = result;
      }
    } catch (e) {
      _showError('Gagal memuat jadwal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Filter by day - Setup stream listener for real-time updates
  Future<void> filterByDay(String day) async {
    try {
      _selectedDay.value = day;
      _isLoading.value = true;

      if (searchController.text.isNotEmpty) {
        searchController.clear();
      }

      _setupRealtimeListener();
    } catch (e) {
      _showError('Gagal memuat jadwal: ${e.toString()}');
      _isLoading.value = false;
    }
  }

  // Search schedules
  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      _filteredSchedules.value = _schedules;
      return;
    }

    _filteredSchedules.value = _schedules.where((schedule) {
      return schedule.doctorName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    _selectedDay.value = _getTodayDayName(); // Reset to today's day
    filterByDay(_selectedDay.value);
  }

  // Refresh data
  Future<void> refreshData() async {
    // Refresh with current day filter
    await filterByDay(_selectedDay.value);
  }

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // Navigate to queue page
  void navigateToQueue() {
    Get.toNamed('/patient/queue');
  }

  // Navigate to doctor list
  void navigateToDoctorList() {
    Get.toNamed('/patient/doctors');
  }

  // Navigate to profile
  void navigateToProfile() {
    Get.toNamed('/patient/profile');
  }
}
