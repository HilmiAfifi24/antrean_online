import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../domain/entities/queue_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/patient_queue_repository.dart';

class QueueController extends GetxController {
  final PatientQueueRepository repository;

  QueueController({required this.repository});

  // Observable variables
  final RxList<QueueEntity> _activeQueues = <QueueEntity>[].obs;
  final RxnInt _currentClinicQueueNumber = RxnInt();
  final RxInt _waitingAheadCount = 0.obs;
  final RxBool _isLoading = false.obs;
  final RxList<ScheduleEntity> _availableRescheduleDates =
      <ScheduleEntity>[].obs;
  final Rxn<ScheduleEntity> _selectedRescheduleSchedule =
      Rxn<ScheduleEntity>();

  // Stream subscription
  StreamSubscription? _queueSubscription;
  StreamSubscription? _currentClinicQueueSubscription;
  StreamSubscription? _waitingCountSubscription;
  StreamSubscription<User?>? _authStateSubscription;
  String? _currentUserId;
  String? _currentClinicKey;
  String? _currentWaitingKey;

  // Getters
  List<QueueEntity> get activeQueues => List.unmodifiable(_activeQueues);
  QueueEntity? get activeQueue =>
      _activeQueues.isEmpty ? null : _activeQueues.first;
  int? get currentClinicQueueNumber => _currentClinicQueueNumber.value;
  int get waitingAheadCount => _waitingAheadCount.value;
  bool get isLoading => _isLoading.value;
  bool get hasActiveQueue => _activeQueues.isNotEmpty;
  List<ScheduleEntity> get availableRescheduleDates =>
      List.unmodifiable(_availableRescheduleDates);
  ScheduleEntity? get selectedRescheduleSchedule =>
      _selectedRescheduleSchedule.value;

  bool get isPatientInClinic {
    final queue = activeQueue;
    final currentQueue = _currentClinicQueueNumber.value;

    if (queue == null || currentQueue == null) {
      return false;
    }

    return queue.queueNumber <= currentQueue;
  }

  int get remainingPatientsBeforeYou {
    final queue = activeQueue;
    if (queue == null) {
      return 0;
    }

    final currentQueue = _currentClinicQueueNumber.value;

    if (currentQueue == null) {
      return _waitingAheadCount.value < 0 ? 0 : _waitingAheadCount.value;
    }

    if (queue.queueNumber <= currentQueue) {
      return 0;
    }

    // waitingAheadCount includes the patient currently called in clinic,
    // while "orang sebelum Anda" should exclude that in-clinic patient.
    final remaining = _waitingAheadCount.value - 1;
    return remaining > 0 ? remaining : 0;
  }

  String get queueProgressLabel {
    final queue = activeQueue;
    if (queue == null) {
      return '';
    }

    if (queue.status == 'dipanggil' || isPatientInClinic) {
      return 'Anda sedang di dalam klinik';
    }

    final remaining = remainingPatientsBeforeYou;
    if (remaining == 0) {
      return 'Anda berikutnya!';
    }

    return 'Sisa $remaining orang sebelum Anda';
  }

  @override
  void onInit() {
    super.onInit();
    _setupAuthStateListener();
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    _queueSubscription?.cancel();
    _currentClinicQueueSubscription?.cancel();
    _waitingCountSubscription?.cancel();
    super.onClose();
  }

  // Setup realtime listener for active queue and react to auth changes
  void _setupAuthStateListener() {
    _authStateSubscription?.cancel();

    void handleAuthChange(User? user) {
      final nextUserId = user?.uid;
      if (_currentUserId == nextUserId) {
        return;
      }

      _currentUserId = nextUserId;
      _queueSubscription?.cancel();
      _activeQueues.clear();
      _bindCurrentClinicQueue(null);
      _bindWaitingCount(null);

      if (nextUserId == null) {
        return;
      }

      _queueSubscription = repository.watchActiveQueues(nextUserId).listen((
        queues,
      ) {
        _activeQueues.assignAll(queues);
        final primaryQueue = queues.isEmpty ? null : queues.first;
        _bindCurrentClinicQueue(primaryQueue);
        _bindWaitingCount(primaryQueue);
      });
    }

    handleAuthChange(FirebaseAuth.instance.currentUser);
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      handleAuthChange,
    );
  }

  void _bindCurrentClinicQueue(QueueEntity? queue) {
    if (queue == null) {
      _currentClinicKey = null;
      _currentClinicQueueSubscription?.cancel();
      _currentClinicQueueNumber.value = null;
      return;
    }

    final normalizedDate = DateTime(
      queue.appointmentDate.year,
      queue.appointmentDate.month,
      queue.appointmentDate.day,
    );
    final nextKey = '${queue.scheduleId}_${normalizedDate.toIso8601String()}';

    if (_currentClinicKey == nextKey) {
      return;
    }

    _currentClinicKey = nextKey;
    _currentClinicQueueSubscription?.cancel();
    _currentClinicQueueSubscription = repository
        .watchCurrentClinicQueueNumber(
          scheduleId: queue.scheduleId,
          appointmentDate: normalizedDate,
        )
        .listen((queueNumber) {
          _currentClinicQueueNumber.value = queueNumber;
        });
  }

  void _bindWaitingCount(QueueEntity? queue) {
    if (queue == null) {
      _currentWaitingKey = null;
      _waitingCountSubscription?.cancel();
      _waitingAheadCount.value = 0;
      return;
    }

    final normalizedDate = DateTime(
      queue.appointmentDate.year,
      queue.appointmentDate.month,
      queue.appointmentDate.day,
    );

    final nextKey =
        '${queue.scheduleId}_${normalizedDate.toIso8601String()}_${queue.queueNumber}';
    if (_currentWaitingKey == nextKey) {
      return;
    }

    _currentWaitingKey = nextKey;
    _waitingCountSubscription?.cancel();
    _waitingCountSubscription = repository
        .watchWaitingCountBeforeQueue(
          scheduleId: queue.scheduleId,
          appointmentDate: normalizedDate,
          queueNumber: queue.queueNumber,
        )
        .listen((count) {
          _waitingAheadCount.value = count;
        });
  }

  // Load active queue
  Future<void> loadActiveQueue() async {
    try {
      _isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final queues = await repository.getActiveQueues(user.uid);
        _activeQueues.assignAll(queues);
      }
    } catch (e) {
      _showError('Gagal memuat antrean: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> validateMultipleBooking({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
  }) {
    return repository.validateMultipleBooking(
      patientId: patientId,
      doctorId: doctorId,
      appointmentDate: appointmentDate,
    );
  }

  Future<bool> validateRescheduleEligibility(QueueEntity queue) async {
    try {
      await repository.validateRescheduleEligibility(queue.id);
      return true;
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> loadAvailableRescheduleDates(QueueEntity queue) async {
    try {
      _isLoading.value = true;
      _selectedRescheduleSchedule.value = null;
      final schedules = await repository.getAvailableRescheduleDates(queue.id);
      _availableRescheduleDates.assignAll(schedules);
      if (schedules.isNotEmpty) {
        _selectedRescheduleSchedule.value = schedules.first;
      }
    } catch (e) {
      _availableRescheduleDates.clear();
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isLoading.value = false;
    }
  }

  void selectRescheduleDate(ScheduleEntity schedule) {
    _selectedRescheduleSchedule.value = schedule;
  }

  Future<bool> rescheduleQueue(QueueEntity queue) async {
    final schedule = _selectedRescheduleSchedule.value;
    if (schedule == null) {
      _showError('Pilih tanggal baru terlebih dahulu');
      return false;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Jadwalkan Ulang?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menjadwalkan ulang antrean ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text(
              'Ya, Reschedule',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      _isLoading.value = true;
      final updated = await repository.rescheduleQueue(
        queueId: queue.id,
        newScheduleId: schedule.id,
        newDate: schedule.date,
      );

      final index = _activeQueues.indexWhere((item) => item.id == queue.id);
      if (index >= 0) {
        _activeQueues[index] = updated;
      } else {
        _activeQueues.add(updated);
      }
      _activeQueues.sort((a, b) {
        final dateCompare = a.appointmentDate.compareTo(b.appointmentDate);
        if (dateCompare != 0) return dateCompare;
        return a.queueNumber.compareTo(b.queueNumber);
      });

      Get.snackbar(
        'Berhasil',
        'Antrean berhasil dijadwalkan ulang. Nomor baru: ${updated.queueNumber}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
      return true;
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Create booking from schedule with multiple-booking validation.
  Future<QueueEntity?> createBooking({
    required ScheduleEntity schedule,
    required String patientName,
    String? patientPhone,
    DateTime? birthDate,
    String? gender,
    required String complaint,
    bool showSuccessMessage = true,
  }) async {
    try {
      _isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('User tidak terautentikasi');
        return null;
      }

      // Check if schedule is full
      if (schedule.isFull) {
        _showError('Maaf, jadwal dokter sudah penuh');
        return null;
      }

      final isValid = await validateMultipleBooking(
        patientId: user.uid,
        doctorId: schedule.doctorId,
        appointmentDate: schedule.date,
      );

      if (!isValid) {
        _showError(
          'Anda sudah memiliki antrean aktif dengan dokter ini pada tanggal tersebut.',
        );
        return null;
      }

      final queue = await repository.createQueue(
        patientId: user.uid,
        patientName: patientName,
        patientPhone: patientPhone,
        birthDate: birthDate,
        gender: gender,
        scheduleId: schedule.id,
        doctorId: schedule.doctorId,
        doctorName: schedule.doctorName,
        doctorSpecialization: schedule.doctorSpecialization,
        appointmentDate: schedule.date,
        appointmentTime: schedule.getTimeRange(),
        complaint: complaint,
      );

      _activeQueues.add(queue);
      _activeQueues.sort((a, b) {
        final dateCompare = a.appointmentDate.compareTo(b.appointmentDate);
        if (dateCompare != 0) return dateCompare;
        return a.queueNumber.compareTo(b.queueNumber);
      });

      if (showSuccessMessage) {
        Get.snackbar(
          'Berhasil',
          'Antrean berhasil dibuat! Nomor antrean Anda: ${queue.queueNumber}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
      }

      return queue;
    } catch (e) {
      final errorMessage =
          e.toString().contains(
            'Anda sudah memiliki antrean aktif dengan dokter ini pada tanggal tersebut.',
          )
          ? 'Anda sudah memiliki antrean aktif dengan dokter ini pada tanggal tersebut.'
          : 'Gagal membuat antrean: ${e.toString()}';
      _showError(errorMessage);
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Create queue from schedule
  Future<void> createQueueFromSchedule({
    required ScheduleEntity schedule,
    required String patientName,
    required String complaint,
  }) async {
    final queue = await createBooking(
      schedule: schedule,
      patientName: patientName,
      complaint: complaint,
    );

    if (queue != null) {
      Get.back();
    }
  }

  // Cancel queue
  Future<void> cancelQueue([QueueEntity? selectedQueue]) async {
    final queue = selectedQueue ?? activeQueue;
    if (queue == null) return;

    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Batalkan Antrean?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan antrean ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Tidak', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Ya, Batalkan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        _isLoading.value = true;
        await repository.cancelQueue(queue.id, queue.scheduleId);
        _activeQueues.removeWhere((item) => item.id == queue.id);

        Get.snackbar(
          'Berhasil',
          'Antrean berhasil dibatalkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _showError('Gagal membatalkan antrean: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.red),
    );
  }

  // Navigate to booking form
  void navigateToBookingForm(ScheduleEntity schedule) {
    // The schedule passed here from BookingDatePickerSheet already has the
    // exact selected date and real-time currentPatients count.
    Get.toNamed('/patient/booking', arguments: schedule);
  }
}
