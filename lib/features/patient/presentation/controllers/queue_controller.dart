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
  final Rxn<QueueEntity> _activeQueue = Rxn<QueueEntity>();
  final RxBool _isLoading = false.obs;
  
  // Stream subscription
  StreamSubscription? _queueSubscription;

  // Getters
  QueueEntity? get activeQueue => _activeQueue.value;
  bool get isLoading => _isLoading.value;
  bool get hasActiveQueue => _activeQueue.value != null;

  @override
  void onInit() {
    super.onInit();
    _setupQueueListener();
  }

  @override
  void onClose() {
    _queueSubscription?.cancel();
    super.onClose();
  }

  // Setup realtime listener for active queue
  void _setupQueueListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _queueSubscription?.cancel();
      _queueSubscription = repository
          .watchActiveQueue(user.uid)
          .listen((queue) {
        _activeQueue.value = queue;
      });
    }
  }

  // Load active queue
  Future<void> loadActiveQueue() async {
    try {
      _isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final queue = await repository.getActiveQueue(user.uid);
        _activeQueue.value = queue;
      }
    } catch (e) {
      _showError('Gagal memuat antrean: ${e.toString()}');
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
    try {
      _isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('User tidak terautentikasi');
        return;
      }

      // Check if schedule is full
      if (schedule.isFull) {
        _showError('Maaf, jadwal dokter sudah penuh');
        return;
      }

      // Create queue
      final queue = await repository.createQueue(
        patientId: user.uid,
        patientName: patientName,
        scheduleId: schedule.id,
        doctorId: schedule.doctorId,
        doctorName: schedule.doctorName,
        doctorSpecialization: schedule.doctorSpecialization,
        appointmentDate: schedule.date,
        appointmentTime: schedule.getTimeRange(),
        complaint: complaint,
      );

      _activeQueue.value = queue;

      Get.snackbar(
        'Berhasil',
        'Antrean berhasil dibuat! Nomor antrean Anda: ${queue.queueNumber}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      // Navigate back to queue page
      Get.back();
    } catch (e) {
      _showError('Gagal membuat antrean: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Cancel queue
  Future<void> cancelQueue() async {
    final queue = _activeQueue.value;
    if (queue == null) return;

    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              child: Text(
                'Tidak',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
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
        _activeQueue.value = null;

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
    // Ensure the schedule.date sent to booking corresponds to a real upcoming
    // date that matches one of the schedule.daysOfWeek values. The UI that
    // selects a day passes selectedDay, but callers here may not — so compute
    // the nearest date for the first supported day in schedule.daysOfWeek.
    DateTime now = DateTime.now();
    DateTime appointmentDate = schedule.date;
    try {
      if (schedule.daysOfWeek.isNotEmpty) {
        // Map Indonesian day names to weekday ints
        final map = {
          'Senin': DateTime.monday,
          'Selasa': DateTime.tuesday,
          'Rabu': DateTime.wednesday,
          'Kamis': DateTime.thursday,
          'Jumat': DateTime.friday,
          'Sabtu': DateTime.saturday,
          'Minggu': DateTime.sunday,
        };
        // Try to compute nearest date for a supported day (prefer near future)
        DateTime? best;
        for (final dayName in schedule.daysOfWeek) {
          final target = map[dayName];
          if (target == null) continue;
          int daysUntil = (target - now.weekday) % 7;
          if (daysUntil < 0) daysUntil += 7;
          final candidate = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntil));
          // choose the earliest candidate >= today
          if (best == null || candidate.isBefore(best)) best = candidate;
        }
        if (best != null) appointmentDate = best;
      }
    } catch (_) {
      // fallback to schedule.date on any error
      appointmentDate = schedule.date;
    }

    final fixed = ScheduleEntity(
      id: schedule.id,
      doctorId: schedule.doctorId,
      doctorName: schedule.doctorName,
      doctorSpecialization: schedule.doctorSpecialization,
      date: appointmentDate,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      daysOfWeek: schedule.daysOfWeek,
      maxPatients: schedule.maxPatients,
      currentPatients: schedule.currentPatients,
      isActive: schedule.isActive,
    );

    Get.toNamed('/patient/booking', arguments: fixed);
  }
}
