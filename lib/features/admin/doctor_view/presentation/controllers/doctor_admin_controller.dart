// features/admin/doctors/presentation/controllers/doctor_controller.dart
import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/get_spesializations.dart';
import 'package:antrean_online/features/admin/doctor_view/presentation/widgets/add_edit_doctor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/usecases/get_all_doctors.dart';
import '../../domain/usecases/get_doctor_by_id.dart';
import '../../domain/usecases/add_doctor.dart';
import '../../domain/usecases/update_doctor.dart';
import '../../domain/usecases/delete_doctor.dart';
import '../../domain/usecases/search_doctors.dart';

class DoctorController extends GetxController {
  final GetAllDoctors getAllDoctors;
  final GetDoctorById getDoctorById;
  final AddDoctor addDoctor;
  final UpdateDoctor updateDoctor;
  final DeleteDoctor deleteDoctor;
  final SearchDoctors searchDoctors;
  final GetSpecializations getSpecializations;

  DoctorController({
    required this.getAllDoctors,
    required this.getDoctorById,
    required this.addDoctor,
    required this.updateDoctor,
    required this.deleteDoctor,
    required this.searchDoctors,
    required this.getSpecializations,
  });

  // Observable variables
  final RxList<DoctorAdminEntity> _doctors = <DoctorAdminEntity>[].obs;
  final RxList<DoctorAdminEntity> _filteredDoctors = <DoctorAdminEntity>[].obs;
  final RxList<String> _specializations = <String>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSearching = false.obs;
  final RxString _selectedSpecialization = ''.obs;
  final RxBool _isFormValid = false.obs;
  final Rxn<DoctorAdminEntity> _currentDoctor = Rxn<DoctorAdminEntity>();

  // Getters
  List<DoctorAdminEntity> get doctors => _doctors.toList();
  List<DoctorAdminEntity> get filteredDoctors => _filteredDoctors.toList();
  List<String> get specializations => _specializations.toList();
  bool get isLoading => _isLoading.value;
  bool get isSearching => _isSearching.value;
  String get selectedSpecialization => _selectedSpecialization.value;
  bool get isFormValid => _isFormValid.value;
  DoctorAdminEntity? get currentDoctor => _currentDoctor.value;

  // Form controllers
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final identificationController = TextEditingController();
  final specializationController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController(); // TAMBAHKAN INI

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
    loadSpecializations();
    
    // Listen to search changes
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        _filteredDoctors.value = _doctors;
        update();
      } else {
        filterDoctors(searchController.text);
      }
    });

    // Listen to form changes
    nameController.addListener(_validateForm);
    identificationController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm); // TAMBAHKAN INI
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    identificationController.dispose();
    specializationController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose(); // TAMBAHKAN INI
    super.onClose();
  }

  // Load all doctors
  Future<void> loadDoctors() async {
    try {
      _isLoading.value = true;
      update();
      final result = await getAllDoctors();
      _doctors.value = result;
      _filteredDoctors.value = result;
      update();
    } catch (e) {
      _showError('Gagal memuat data dokter: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Load specializations
  Future<void> loadSpecializations() async {
    try {
      final result = await getSpecializations();
      _specializations.value = result;
      update();
    } catch (e) {
      // Silent fail for specializations
    }
  }

  // Search doctors
  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      _filteredDoctors.value = _doctors;
      update();
      return;
    }

    try {
      _isSearching.value = true;
      update();
      final result = await searchDoctors(query);
      _filteredDoctors.value = result;
      update();
    } catch (e) {
      _showError('Gagal mencari dokter: ${e.toString()}');
    } finally {
      _isSearching.value = false;
      update();
    }
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    _selectedSpecialization.value = '';
    _filteredDoctors.value = _doctors;
    update();
  }

  // Simple search for UI
  void filterDoctors(String query) {
    if (query.isEmpty) {
      _filteredDoctors.value = _doctors;
    } else {
      _filteredDoctors.value = _doctors
          .where((doctor) =>
              doctor.namaLengkap.toLowerCase().contains(query.toLowerCase()) ||
              doctor.spesialisasi.toLowerCase().contains(query.toLowerCase()) ||
              doctor.nomorIdentifikasi.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    update();
  }

  // Filter by specialization
  void filterBySpecialization(String specialization) {
    _selectedSpecialization.value = specialization;
    if (specialization.isEmpty || specialization == 'Semua') {
      _filteredDoctors.value = _doctors;
    } else {
      _filteredDoctors.value = _doctors
          .where((doctor) => doctor.spesialisasi == specialization)
          .toList();
    }
    update();
  }

  // Add new doctor dengan validasi lengkap
  Future<void> addNewDoctor() async {
    if (!_isFormValid.value) return;

    try {
      _isLoading.value = true;
      update();

      // VALIDASI 1: Email harus berakhiran @pens.ac.id
      final email = emailController.text.trim();
      if (!email.endsWith('@pens.ac.id')) {
        _showError('Email harus menggunakan domain @pens.ac.id');
        return;
      }

      // VALIDASI 2: Cek nomor identifikasi sudah ada atau belum
      final identificationExists = await Get.find<DoctorAdminRepository>()
          .isIdentificationNumberExists(identificationController.text.trim());
      if (identificationExists) {
        _showError('Nomor identifikasi sudah digunakan oleh dokter lain');
        return;
      }

      // VALIDASI 3: Cek nomor telepon sudah ada atau belum
      final phoneExists = await Get.find<DoctorAdminRepository>()
          .isPhoneNumberExists(phoneController.text.trim());
      if (phoneExists) {
        _showError('Nomor telepon sudah digunakan oleh dokter lain');
        return;
      }

      // VALIDASI 4: Cek email sudah ada atau belum
      final emailExists = await Get.find<DoctorAdminRepository>()
          .isEmailExists(email);
      if (emailExists) {
        _showError('Email sudah digunakan oleh dokter lain');
        return;
      }

      final doctor = DoctorAdminEntity(
        id: '', // Will be generated by Firestore
        userId: '', // Will be generated when creating user account
        namaLengkap: nameController.text.trim(),
        nomorIdentifikasi: identificationController.text.trim(),
        spesialisasi: _selectedSpecialization.value,
        nomorTelepon: phoneController.text.trim(),
        email: email,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Simpan dengan password
      await addDoctor(doctor, passwordController.text.trim());
      _clearForm();
      await loadDoctors(); // Refresh list
      Get.back(); // Close form dialog

      _showSuccess('Dokter berhasil ditambahkan');
    } catch (e) {
      _showError('Gagal menambahkan dokter: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Update existing doctor dengan validasi lengkap
  Future<void> updateExistingDoctor(String id) async {
    if (!_isFormValid.value || _currentDoctor.value == null) return;

    try {
      _isLoading.value = true;
      update();

      // VALIDASI 1: Email harus berakhiran @pens.ac.id
      final email = emailController.text.trim();
      if (!email.endsWith('@pens.ac.id')) {
        _showError('Email harus menggunakan domain @pens.ac.id');
        return;
      }

      // VALIDASI 2: Cek nomor identifikasi sudah ada atau belum (exclude current doctor)
      final identificationExists = await Get.find<DoctorAdminRepository>()
          .isIdentificationNumberExists(
            identificationController.text.trim(),
            excludeDoctorId: id,
          );
      if (identificationExists) {
        _showError('Nomor identifikasi sudah digunakan oleh dokter lain');
        return;
      }

      // VALIDASI 3: Cek nomor telepon sudah ada atau belum (exclude current doctor)
      final phoneExists = await Get.find<DoctorAdminRepository>()
          .isPhoneNumberExists(
            phoneController.text.trim(),
            excludeDoctorId: id,
          );
      if (phoneExists) {
        _showError('Nomor telepon sudah digunakan oleh dokter lain');
        return;
      }

      // VALIDASI 4: Cek email sudah ada atau belum (exclude current doctor)
      final emailExists = await Get.find<DoctorAdminRepository>()
          .isEmailExists(
            email,
            excludeDoctorId: id,
          );
      if (emailExists) {
        _showError('Email sudah digunakan oleh dokter lain');
        return;
      }

      final doctor = _currentDoctor.value!.copyWith(
        namaLengkap: nameController.text.trim(),
        nomorIdentifikasi: identificationController.text.trim(),
        spesialisasi: _selectedSpecialization.value,
        nomorTelepon: phoneController.text.trim(),
        email: email,
        updatedAt: DateTime.now(),
      );

      await updateDoctor(id, doctor);
      _clearForm();
      await loadDoctors(); // Refresh list
      Get.back(); // Close form dialog

      _showSuccess('Data dokter berhasil diperbarui');
    } catch (e) {
      _showError('Gagal memperbarui data dokter: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Delete doctor
  Future<void> removeDoctor(String id, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus dokter $name?\n\n'
          'PERHATIAN: Tindakan ini akan menghapus data secara permanen dan tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      _isLoading.value = true;
      final doctorRepo = Get.find<DoctorAdminRepository>();
      await doctorRepo.permanentlyDeleteDoctor(id);  // Implement this method in repository
      await loadDoctors(); // Refresh list
      _showSuccess('Dokter berhasil dihapus secara permanen');
    } catch (e) {
      _showError('Gagal menghapus dokter: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Load doctor data for editing
  Future<void> loadDoctorForEdit(String id) async {
    try {
      _isLoading.value = true;
      final doctor = await getDoctorById(id);
      
      if (doctor != null) {
        _currentDoctor.value = doctor;
        _populateForm(doctor);
      }
    } catch (e) {
      _showError('Gagal memuat data dokter: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Populate form with doctor data
  void _populateForm(DoctorAdminEntity doctor) {
    nameController.text = doctor.namaLengkap;
    identificationController.text = doctor.nomorIdentifikasi;
    _selectedSpecialization.value = doctor.spesialisasi;
    phoneController.text = doctor.nomorTelepon;
    emailController.text = doctor.email;
    // Tidak mengisi password saat edit (keamanan)
    _validateForm();
  }

  // Clear form
  void _clearForm() {
    nameController.clear();
    identificationController.clear();
    specializationController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear(); // TAMBAHKAN INI
    _selectedSpecialization.value = '';
    _currentDoctor.value = null;
    _isFormValid.value = false;
  }

  // Validate form dengan validasi email domain @pens.ac.id
  void _validateForm() {
    final name = nameController.text.trim();
    final identification = identificationController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final specialization = _selectedSpecialization.value;

    // Untuk add: perlu password, untuk edit: tidak perlu password
    final isAddMode = _currentDoctor.value == null;
    
    // Validasi email format dan domain @pens.ac.id
    final isEmailValid = GetUtils.isEmail(email) && email.endsWith('@pens.ac.id');
    
    // Validasi nomor telepon (hanya angka, minimal 10 digit)
    final isPhoneValid = phone.isNotEmpty && 
                         RegExp(r'^[0-9]{10,15}$').hasMatch(phone);
    
    _isFormValid.value = name.isNotEmpty &&
        identification.isNotEmpty &&
        isPhoneValid &&
        isEmailValid &&
        specialization.isNotEmpty &&
        (isAddMode ? password.length >= 6 : true); // Password minimal 6 karakter untuk add
  }

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      borderRadius: 12,
    );
  }

  // Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      borderRadius: 12,
    );
  }

  // Show add doctor dialog
  void showAddDoctorDialog() {
    _clearForm();
    Get.dialog(
      const AddEditDoctorDialog(isEditing: false),
      barrierDismissible: false,
    );
  }

  // Show edit doctor dialog
  void showEditDoctorDialog(DoctorAdminEntity doctor) {
    _currentDoctor.value = doctor;
    _populateForm(doctor);
    Get.dialog(
      const AddEditDoctorDialog(isEditing: true),
      barrierDismissible: false,
    );
  }

  // Future<void> toggleDoctorStatus(String id, bool currentStatus) async {
  //   final action = currentStatus ? 'menonaktifkan' : 'mengaktifkan';
    
  //   final confirmed = await Get.dialog<bool>(
  //     AlertDialog(
  //       title: Text('Konfirmasi ${currentStatus ? 'Nonaktifkan' : 'Aktifkan'}'),
  //       content: Text('Apakah Anda yakin ingin $action dokter ini?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(result: false),
  //           child: const Text('Batal'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Get.back(result: true),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: currentStatus 
  //                 ? const Color(0xFFEF4444)
  //                 : const Color(0xFF10B981),
  //           ),
  //           child: Text(
  //             currentStatus ? 'Nonaktifkan' : 'Aktifkan',
  //             style: const TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed != true) return;

  //   try {
  //     _isLoading.value = true;
      
  //     final doctorRepo = Get.find<DoctorAdminRepository>();
  //     if (currentStatus) {
  //       // Hanya mengubah status aktif
  //       await doctorRepo.updateDoctorStatus(id, false);
  //     } else {
  //       // Aktivasi dokter
  //       await doctorRepo.updateDoctorStatus(id, true);
  //     }
      
  //     await loadDoctors(); // Refresh list
  //     _showSuccess(currentStatus 
  //         ? 'Dokter berhasil dinonaktifkan' 
  //         : 'Dokter berhasil diaktifkan');
  //   } catch (e) {
  //     _showError('Gagal ${currentStatus ? 'menonaktifkan' : 'mengaktifkan'} dokter: ${e.toString()}');
  //   } finally {
  //     _isLoading.value = false;
  //   }
  // }

  // Method untuk validasi form (perbaiki akses)
  void validateForm() {
    _validateForm();
  }

  // Public setters untuk specialization
  void setSelectedSpecialization(String specialization) {
    _selectedSpecialization.value = specialization;
    _validateForm();
    update();
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadDoctors();
    await loadSpecializations();
  }
}