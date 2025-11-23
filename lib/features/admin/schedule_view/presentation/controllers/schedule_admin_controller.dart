import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_all_schedules.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_schedule_by_id.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/add_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/update_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/delete_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/activate_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/search_schedules.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_schedules_by_doctor.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/widgets/add_edit_schedule_dialog.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/get_all_doctors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ScheduleController extends GetxController {
  final GetAllSchedules getAllSchedules;
  final GetScheduleById getScheduleById;
  final AddSchedule addSchedule;
  final UpdateSchedule updateSchedule;
  final DeleteSchedule deleteSchedule;
  final ActivateSchedule activateSchedule;
  final SearchSchedules searchSchedules;
  final GetSchedulesByDoctor getSchedulesByDoctor;
  final GetAllDoctors getAllDoctors;

  ScheduleController({
    required this.getAllSchedules,
    required this.getScheduleById,
    required this.addSchedule,
    required this.updateSchedule,
    required this.deleteSchedule,
    required this.activateSchedule,
    required this.searchSchedules,
    required this.getSchedulesByDoctor,
    required this.getAllDoctors,
  });

  // Observable variables
  final RxList<ScheduleAdminEntity> _schedules = <ScheduleAdminEntity>[].obs;
  final RxList<ScheduleAdminEntity> _filteredSchedules = <ScheduleAdminEntity>[].obs;
  final RxList<DoctorAdminEntity> _doctors = <DoctorAdminEntity>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSearching = false.obs;
  final RxString _selectedDoctorId = ''.obs;
  final RxBool _isFormValid = false.obs;
  final Rxn<ScheduleAdminEntity> _currentSchedule = Rxn<ScheduleAdminEntity>();
  final RxBool _includeInactive = false.obs;

  // Stream subscriptions for realtime updates
  StreamSubscription? _doctorsSubscription;
  StreamSubscription? _schedulesSubscription;

  // Getters
  List<ScheduleAdminEntity> get schedules => _schedules.toList();
  List<ScheduleAdminEntity> get filteredSchedules => _filteredSchedules.toList();
  List<DoctorAdminEntity> get doctors => _doctors.toList();
  bool get isLoading => _isLoading.value;
  bool get isSearching => _isSearching.value;
  String get selectedDoctorId => _selectedDoctorId.value;
  bool get isFormValid => _isFormValid.value;
  ScheduleAdminEntity? get currentSchedule => _currentSchedule.value;
  bool get includeInactive => _includeInactive.value;

  // Form controllers
  final searchController = TextEditingController();
  final doctorController = TextEditingController();
  final maxPatientsController = TextEditingController();
  
  // Form variables
  final Rxn<DateTime> _selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> _startTime = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> _endTime = Rxn<TimeOfDay>();
  final RxList<String> _selectedDays = <String>[].obs;
  final Rxn<DoctorAdminEntity> _selectedDoctor = Rxn<DoctorAdminEntity>();

  // Form getters
  DateTime? get selectedDate => _selectedDate.value;
  TimeOfDay? get startTime => _startTime.value;
  TimeOfDay? get endTime => _endTime.value;
  List<String> get selectedDays => _selectedDays.toList();
  DoctorAdminEntity? get selectedDoctor => _selectedDoctor.value;

  // Available days
  final List<String> availableDays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
    loadDoctors();
    _setupRealtimeListeners();
    
    // Listen to search changes
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        _filteredSchedules.value = _schedules;
        update();
      } else {
        filterSchedules(searchController.text);
      }
    });

    // Listen to form changes
    maxPatientsController.addListener(_validateForm);
  }

  // Setup realtime listeners untuk auto-update data
  void _setupRealtimeListeners() {
    // Cancel existing subscriptions
    _doctorsSubscription?.cancel();
    _schedulesSubscription?.cancel();

    // Listen to doctors collection untuk auto-update list dokter
    _doctorsSubscription = FirebaseFirestore.instance
        .collection('doctors')
        .where('is_active', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      loadDoctors(); // Reload doctors when collection changes
    });

    // Listen to schedules collection untuk auto-update list jadwal
    _schedulesSubscription = FirebaseFirestore.instance
        .collection('schedules')
        .snapshots()
        .listen((snapshot) {
      loadSchedules(); // Reload schedules when collection changes
    });
  }

  @override
  void onClose() {
    // Cancel subscriptions to prevent memory leaks
    _doctorsSubscription?.cancel();
    _schedulesSubscription?.cancel();
    
    // Dispose controllers
    searchController.dispose();
    doctorController.dispose();
    maxPatientsController.dispose();
    super.onClose();
  }

  // Load all schedules
  Future<void> loadSchedules() async {
    try {
      _isLoading.value = true;
      update();
      final result = await getAllSchedules(includeInactive: _includeInactive.value);
      _schedules.value = result;
      _filteredSchedules.value = result;
      update();
    } catch (e) {
      _showError('Gagal memuat data jadwal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Load all doctors
  Future<void> loadDoctors() async {
    try {
      final result = await getAllDoctors();
      _doctors.value = result;
      update();
    } catch (e) {
      // Silent fail for doctors
    }
  }

  // Simple search for UI
  void filterSchedules(String query) {
    if (query.isEmpty) {
      _filteredSchedules.value = _schedules;
    } else {
      _filteredSchedules.value = _schedules
          .where((schedule) =>
              schedule.doctorName.toLowerCase().contains(query.toLowerCase()) ||
              schedule.doctorSpecialization.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    update();
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    _selectedDoctorId.value = '';
    _filteredSchedules.value = _schedules;
    update();
  }

  // Filter by doctor
  void filterByDoctor(String doctorId) {
    _selectedDoctorId.value = doctorId;
    if (doctorId.isEmpty || doctorId == 'Semua') {
      _filteredSchedules.value = _schedules;
    } else {
      _filteredSchedules.value = _schedules
          .where((schedule) => schedule.doctorId == doctorId)
          .toList();
    }
    update();
  }

  // Toggle include inactive
  void toggleIncludeInactive() {
    _includeInactive.value = !_includeInactive.value;
    loadSchedules();
  }

  // Set selected date
  void setSelectedDate(DateTime? date) {
    _selectedDate.value = date;
    _validateForm();
  }

  // Set start time
  void setStartTime(TimeOfDay? time) {
    _startTime.value = time;
    _validateForm();
  }

  // Set end time
  void setEndTime(TimeOfDay? time) {
    _endTime.value = time;
    _validateForm();
  }

  // Set selected doctor
  void setSelectedDoctor(DoctorAdminEntity? doctor) {
    _selectedDoctor.value = doctor;
    if (doctor != null) {
      doctorController.text = doctor.namaLengkap;
    }
    _validateForm();
  }

  // Toggle day selection
  void toggleDay(String day) {
    if (_selectedDays.contains(day)) {
      _selectedDays.remove(day);
    } else {
      _selectedDays.add(day);
    }
    _validateForm();
  }

  // Add new schedule
  Future<void> addNewSchedule() async {
    if (!_isFormValid.value) return;

    try {
      _isLoading.value = true;
      update();

      final schedule = ScheduleAdminEntity(
        id: '',
        doctorId: _selectedDoctor.value!.userId,  // FIX: Use userId (Firebase Auth UID) instead of document ID
        doctorName: _selectedDoctor.value!.namaLengkap,
        doctorSpecialization: _selectedDoctor.value!.spesialisasi,
        date: _selectedDate.value!,
        startTime: _startTime.value!,
        endTime: _endTime.value!,
        daysOfWeek: _selectedDays.toList(),
        maxPatients: int.parse(maxPatientsController.text.trim()),
        currentPatients: 0,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await addSchedule(schedule);
      _clearForm();
      await loadSchedules();
      Get.back();

      _showSuccess('Jadwal berhasil ditambahkan');
    } catch (e) {
      _showError('Gagal menambahkan jadwal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Update existing schedule
  Future<void> updateExistingSchedule(String id) async {
    if (!_isFormValid.value || _currentSchedule.value == null) return;

    try {
      _isLoading.value = true;
      update();

      final schedule = _currentSchedule.value!.copyWith(
        doctorId: _selectedDoctor.value!.userId,  // FIX: Use userId (Firebase Auth UID) instead of document ID
        doctorName: _selectedDoctor.value!.namaLengkap,
        doctorSpecialization: _selectedDoctor.value!.spesialisasi,
        date: _selectedDate.value!,
        startTime: _startTime.value!,
        endTime: _endTime.value!,
        daysOfWeek: _selectedDays.toList(),
        maxPatients: int.parse(maxPatientsController.text.trim()),
        updatedAt: DateTime.now(),
      );

      await updateSchedule(id, schedule);
      _clearForm();
      await loadSchedules();
      Get.back();

      _showSuccess('Jadwal berhasil diperbarui');
    } catch (e) {
      _showError('Gagal memperbarui jadwal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Delete schedule
  Future<void> deleteScheduleById(String id) async {
    try {
      _isLoading.value = true;
      update();

      await deleteSchedule(id);
      await loadSchedules();

      _showSuccess('Jadwal berhasil dihapus');
    } catch (e) {
      _showError('Gagal menghapus jadwal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Activate schedule
  Future<void> activateScheduleById(String id) async {
    try {
      _isLoading.value = true;
      update();

      await activateSchedule(id);
      await loadSchedules();

      _showSuccess('Jadwal berhasil diaktifkan');
    } catch (e) {
      _showError('Gagal mengaktifkan jadwal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Show add schedule dialog
  void showAddScheduleDialog() {
    _clearForm();
    _currentSchedule.value = null;
    Get.dialog(
      const AddEditScheduleDialog(),
      barrierDismissible: false,
    );
  }

  // Show edit schedule dialog
  void showEditScheduleDialog(ScheduleAdminEntity schedule) {
    _currentSchedule.value = schedule;
    _fillFormWithSchedule(schedule);
    Get.dialog(
      const AddEditScheduleDialog(),
      barrierDismissible: false,
    );
  }

  // Fill form with schedule data
  void _fillFormWithSchedule(ScheduleAdminEntity schedule) {
    _selectedDate.value = schedule.date;
    _startTime.value = schedule.startTime;
    _endTime.value = schedule.endTime;
    _selectedDays.value = schedule.daysOfWeek;
    maxPatientsController.text = schedule.maxPatients.toString();
    
    // Find and set doctor
    final doctor = _doctors.firstWhereOrNull((d) => d.id == schedule.doctorId);
    if (doctor != null) {
      setSelectedDoctor(doctor);
    }
    
    _validateForm();
  }

  // Clear form
  void _clearForm() {
    _selectedDate.value = null;
    _startTime.value = null;
    _endTime.value = null;
    _selectedDays.clear();
    _selectedDoctor.value = null;
    doctorController.clear();
    maxPatientsController.clear();
    _isFormValid.value = false;
  }

  // Validate form
  void _validateForm() {
    _isFormValid.value = _selectedDoctor.value != null &&
        _selectedDate.value != null &&
        _startTime.value != null &&
        _endTime.value != null &&
        _selectedDays.isNotEmpty &&
        maxPatientsController.text.trim().isNotEmpty &&
        int.tryParse(maxPatientsController.text.trim()) != null &&
        int.parse(maxPatientsController.text.trim()) > 0;
    update();
  }

  // Show error snackbar
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

  // Show success snackbar
  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
}