import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_all_schedules.dart' as schedule_admin_usecases;
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_schedule_by_id.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/add_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/update_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/delete_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/activate_schedule.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/search_schedules.dart';
import 'package:antrean_online/features/admin/schedule_view/domain/usecases/get_schedules_by_doctor.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/widgets/add_edit_schedule_dialog.dart';
import 'package:antrean_online/features/admin/schedule_view/data/models/schedule_admin_model.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/entities/doctor_admin_entity.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/get_all_doctors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:antrean_online/features/auth/presentation/controllers/auth_controller.dart';
import 'package:antrean_online/core/utils/app_snackbar.dart';

class ScheduleController extends GetxController {
  final schedule_admin_usecases.GetAllSchedules getAllSchedules;
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
  Worker? _authUserWorker;
  Worker? _authReadyWorker;
  AuthController? _authController;
  bool _hasAdminAccess = false;

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
    _bindAuthState();
    
    // Listen to search changes
    searchController.addListener(() {
      _applyFilters();
    });

    // Listen to form changes
    maxPatientsController.addListener(_validateForm);
  }

  bool _canAccessAdminData() {
    final auth = _authController ??
        (Get.isRegistered<AuthController>()
            ? Get.find<AuthController>()
            : null);
    final user = auth?.currentUser.value;
    return auth?.isSessionReady.value == true && user?.role == 'admin';
  }

  void _bindAuthState() {
    if (!Get.isRegistered<AuthController>()) {
      return;
    }

    _authController = Get.find<AuthController>();
    _authUserWorker?.dispose();
    _authReadyWorker?.dispose();

    _authUserWorker = ever(_authController!.currentUser, (_) {
      _syncAdminAccess();
    });

    _authReadyWorker = ever(_authController!.isSessionReady, (_) {
      _syncAdminAccess();
    });

    _syncAdminAccess();
  }

  void _syncAdminAccess() {
    final canAccess = _canAccessAdminData();
    if (canAccess == _hasAdminAccess) {
      return;
    }

    _hasAdminAccess = canAccess;
    if (!canAccess) {
      _doctorsSubscription?.cancel();
      _schedulesSubscription?.cancel();
      _doctors.clear();
      _schedules.clear();
      _filteredSchedules.clear();
      return;
    }

    loadSchedules();
    loadDoctors();
    _setupRealtimeListeners();
  }

  // Setup realtime listeners untuk auto-update data
  void _setupRealtimeListeners() {
    if (!_canAccessAdminData()) {
      return;
    }

    // Cancel existing subscriptions
    _doctorsSubscription?.cancel();
    _schedulesSubscription?.cancel();

    // Listen to doctors collection untuk auto-update list dokter
    _doctorsSubscription = FirebaseFirestore.instance
        .collection('doctors')
        .where('is_active', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      if (isClosed) return;
      _doctors.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return DoctorAdminEntity(
          id: doc.id,
          userId: data['user_id'] ?? '',
          namaLengkap: data['nama_lengkap'] ?? '',
          nomorIdentifikasi: data['nomor_identifikasi'] ?? '',
          spesialisasi: data['spesialisasi'] ?? '',
          nomorTelepon: data['nomor_telepon'] ?? '',
          email: data['email'] ?? '',
          isActive: data['is_active'] ?? true,
          createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
        );
        }).toList();
      update();
    }, onError: (error) {
      if (isClosed) return;
      debugPrint('Failed to listen to doctors collection: $error');
    });

    // Listen to schedules collection untuk auto-update list jadwal
    Query schedulesQuery = FirebaseFirestore.instance.collection('schedules');
    if (!_includeInactive.value) {
      schedulesQuery = schedulesQuery.where('is_active', isEqualTo: true);
    }

    _schedulesSubscription = schedulesQuery.snapshots().listen((snapshot) {
      if (isClosed) return;
      _schedules.value = snapshot.docs
          .map((doc) => ScheduleAdminModel.fromFirestore(doc))
          .toList();
      _applyFilters();
    }, onError: (error) {
      if (isClosed) return;
      debugPrint('Failed to listen to schedules collection: $error');
    });
  }

  @override
  void onClose() {
    // Cancel subscriptions to prevent memory leaks
    _doctorsSubscription?.cancel();
    _schedulesSubscription?.cancel();
    _authUserWorker?.dispose();
    _authReadyWorker?.dispose();
    
    // Dispose controllers
    searchController.dispose();
    doctorController.dispose();
    maxPatientsController.dispose();
    super.onClose();
  }

  // Load all schedules
  Future<void> loadSchedules() async {
    if (!_canAccessAdminData()) {
      return;
    }

    try {
      _isLoading.value = true;
      update();
      final result = await getAllSchedules(includeInactive: _includeInactive.value);
      
      // Don't expand here - let the UI handle display per day
      // But datasource already calculates currentPatients correctly
      _schedules.value = result;
      _applyFilters();
      update();
    } catch (e) {
      _showError('Gagal memuat data jadwal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }
  
  // Get expanded schedules for display (separate card per day)
  List<ScheduleAdminEntity> getExpandedSchedules() {
    final expandedSchedules = <ScheduleAdminEntity>[];
    for (final schedule in _filteredSchedules) {
      if (schedule.daysOfWeek.length == 1) {
        // Already single day, add as is
        expandedSchedules.add(schedule);
      } else {
        // Multiple days, split into separate schedules for display only
        for (final day in schedule.daysOfWeek) {
          // Calculate patient count for this specific day
          final today = DateTime.now();
          final todayDayName = _getDayName(today.weekday);
          final isToday = day == todayDayName;
          
          expandedSchedules.add(
            schedule.copyWith(
              daysOfWeek: [day],
              currentPatients: isToday ? schedule.currentPatients : 0,
            ),
          );
        }
      }
    }
    return expandedSchedules;
  }
  
  // Helper method to convert weekday number to Indonesian day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return '';
    }
  }

  // Load all doctors
  Future<void> loadDoctors() async {
    if (!_canAccessAdminData()) {
      return;
    }

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
    if (searchController.text != query) {
      searchController.text = query;
    }
    _applyFilters();
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    _selectedDoctorId.value = '';
    _applyFilters();
  }

  // Filter by doctor
  void filterByDoctor(String doctorId) {
    _selectedDoctorId.value = doctorId;
    _applyFilters();
  }

  // Toggle include inactive
  void toggleIncludeInactive() {
    _includeInactive.value = !_includeInactive.value;
    _setupRealtimeListeners();
  }

  void _applyFilters() {
    Iterable<ScheduleAdminEntity> items = _schedules;

    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items.where(
        (schedule) =>
            schedule.doctorName.toLowerCase().contains(query) ||
            schedule.doctorSpecialization.toLowerCase().contains(query),
      );
    }

    if (_selectedDoctorId.value.isNotEmpty && _selectedDoctorId.value != 'Semua') {
      items = items.where((schedule) => schedule.doctorId == _selectedDoctorId.value);
    }

    _filteredSchedules.value = items.toList();
    update();
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
  Future<void> addNewSchedule(BuildContext context) async {
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
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      await loadSchedules();

      _showSuccess('Jadwal berhasil ditambahkan');
    } catch (e) {
      _showError('Gagal menambahkan jadwal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Update existing schedule
  Future<void> updateExistingSchedule(String id, BuildContext context) async {
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
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      await loadSchedules();

      _showSuccess('Jadwal berhasil diperbarui');
    } catch (e) {
      _showError('Gagal memperbarui jadwal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Delete schedule with confirmation
  Future<void> deleteScheduleById(String id, BuildContext context, {String? dayToDeactivate}) async {
    try {
      final scheduleData = _schedules.firstWhereOrNull((schedule) => schedule.id == id) ??
          await getScheduleById(id);
      
      if (scheduleData == null) {
        throw Exception('Jadwal tidak ditemukan');
      }

      final isPartialDeactivate = dayToDeactivate != null && scheduleData.daysOfWeek.length > 1;
      final queueCount = scheduleData.currentPatients;
      final doctorName = scheduleData.doctorName;
      final scheduleInfo = isPartialDeactivate
          ? '$dayToDeactivate (${scheduleData.startTime.hour.toString().padLeft(2, '0')}:${scheduleData.startTime.minute.toString().padLeft(2, '0')} - ${scheduleData.endTime.hour.toString().padLeft(2, '0')}:${scheduleData.endTime.minute.toString().padLeft(2, '0')})'
          : '${scheduleData.daysOfWeek.join(', ')} (${scheduleData.startTime.hour.toString().padLeft(2, '0')}:${scheduleData.startTime.minute.toString().padLeft(2, '0')} - ${scheduleData.endTime.hour.toString().padLeft(2, '0')}:${scheduleData.endTime.minute.toString().padLeft(2, '0')})';

      if (!context.mounted) return;

      // Tampilkan dialog konfirmasi
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isPartialDeactivate ? 'Nonaktifkan Hari Praktik?' : 'Nonaktifkan Jadwal?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPartialDeactivate
                      ? 'Anda akan menonaktifkan hari praktik:'
                      : 'Anda akan menonaktifkan jadwal:',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPartialDeactivate
                      ? 'Hari ini akan dihapus dari jadwal praktek dokter.'
                      : 'Jadwal ini akan disembunyikan dari daftar aktif.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Color(0xFF3B82F6), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDoctorName(doctorName),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF64748B), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              scheduleInfo,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (queueCount > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'PERHATIAN!',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              isPartialDeactivate
                                  ? '$queueCount data antrean pada jadwal ini akan terpengaruh'
                                  : '$queueCount data antrean akan dihapus',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tindakan ini tidak dapat dibatalkan!',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Nonaktifkan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      _isLoading.value = true;
      update();

      if (isPartialDeactivate) {
        final updatedDays = List<String>.from(scheduleData.daysOfWeek)..remove(dayToDeactivate);
        final updatedSchedule = scheduleData.copyWith(
          daysOfWeek: updatedDays,
          updatedAt: DateTime.now(),
        );
        await updateSchedule(id, updatedSchedule);
        await loadSchedules();
        _showSuccess('Hari $dayToDeactivate berhasil dihapus dari jadwal');
      } else {
        await deleteSchedule(id);
        await loadSchedules();
        _showSuccess('Jadwal berhasil dinonaktifkan');
      }
    } catch (e) {
      _showError('Gagal menonaktifkan jadwal: ${e.toString()}');
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
  void showAddScheduleDialog(BuildContext context) {
    _clearForm();
    _currentSchedule.value = null;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const AddEditScheduleDialog();
      },
    );
  }

  // Show edit schedule dialog
  void showEditScheduleDialog(ScheduleAdminEntity schedule, BuildContext context) {
    // Find the original full schedule from the schedules list to get all days of week
    final originalSchedule = _schedules.firstWhereOrNull((s) => s.id == schedule.id) ?? schedule;
    _currentSchedule.value = originalSchedule;
    _fillFormWithSchedule(originalSchedule);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const AddEditScheduleDialog();
      },
    );
  }

  // Fill form with schedule data
  void _fillFormWithSchedule(ScheduleAdminEntity schedule) {
    _selectedDate.value = schedule.date;
    _startTime.value = schedule.startTime;
    _endTime.value = schedule.endTime;
    _selectedDays.value = List<String>.from(schedule.daysOfWeek);
    maxPatientsController.text = schedule.maxPatients.toString();
    
    // Find and set doctor
    final doctor = _doctors.firstWhereOrNull((d) => d.userId == schedule.doctorId || d.id == schedule.doctorId);
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
  String _formatDoctorName(String name) {
    final trimmed = name.trim();
    final withoutPrefix = trimmed.replaceFirst(
      RegExp(r'^(dr\.?\s*)', caseSensitive: false),
      '',
    );
    return 'dr. $withoutPrefix';
  }

  // Show error snackbar
  void _showError(String message) {
    AppSnackbar.show(
      title: 'Error',
      message: message,
      isError: true,
    );
  }

  // Show success snackbar
  void _showSuccess(String message) {
    AppSnackbar.show(
      title: 'Berhasil',
      message: message,
      isError: false,
    );
  }
}
