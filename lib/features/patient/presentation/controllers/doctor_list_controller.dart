import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/usecases/get_all_doctors.dart';

class DoctorListController extends GetxController {
  final GetAllDoctors getAllDoctors;

  DoctorListController({required this.getAllDoctors});

  // Observable variables
  final RxList<DoctorEntity> _doctors = <DoctorEntity>[].obs;
  final RxList<DoctorEntity> _filteredDoctors = <DoctorEntity>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchText = ''.obs;

  // Stream subscription
  StreamSubscription? _doctorsSubscription;

  // Getters
  List<DoctorEntity> get doctors => _doctors.toList();
  List<DoctorEntity> get filteredDoctors => _filteredDoctors.toList();
  bool get isLoading => _isLoading.value;
  String get searchText => _searchText.value;

  // Search controller
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
    _setupRealtimeListener();

    // Listen to search changes
    searchController.addListener(() {
      _searchText.value = searchController.text;
      performSearch(searchController.text);
    });
  }

  @override
  void onClose() {
    _doctorsSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // Setup realtime listener
  void _setupRealtimeListener() {
    _doctorsSubscription?.cancel();

    _doctorsSubscription = FirebaseFirestore.instance
        .collection('doctors')
        .where('is_active', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      try {
        final doctors = snapshot.docs.map((doc) {
          final data = doc.data();
          return DoctorEntity(
            id: doc.id,
            name: data['name'] ?? '',
            specialization: data['specialization'] ?? '',
            phone: data['phone'] ?? '',
            email: data['email'] ?? '',
            isActive: data['is_active'] ?? false,
          );
        }).toList();

        _doctors.value = doctors;

        // Apply search filter if active
        if (_searchText.value.isNotEmpty) {
          performSearch(_searchText.value);
        } else {
          _filteredDoctors.value = doctors;
        }
      } catch (e) {
        _showError('Error loading doctors: $e');
      }
    });
  }

  // Load all doctors
  Future<void> loadDoctors() async {
    try {
      _isLoading.value = true;

      final result = await getAllDoctors();
      _doctors.value = result;
      _filteredDoctors.value = result;
    } catch (e) {
      _showError('Gagal memuat dokter: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Search doctors
  void performSearch(String query) {
    if (query.isEmpty) {
      _filteredDoctors.value = _doctors;
      return;
    }

    _filteredDoctors.value = _doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(query.toLowerCase()) ||
          doctor.specialization.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    _searchText.value = '';
    _filteredDoctors.value = _doctors;
  }

  // Show doctor detail
  void showDoctorDetail(DoctorEntity doctor) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  doctor.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    doctor.displaySpecialization,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doctor.phone.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.phone, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      doctor.phone,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (doctor.email.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.email, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      doctor.email,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Show error
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[50],
      colorText: Colors.red[900],
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Color(0xFFE53935)),
    );
  }
}
