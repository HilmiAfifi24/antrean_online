import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/usecases/send_queue_opened_notifications.dart';
import '../../domain/usecases/send_practice_started_notifications.dart';
import '../../domain/usecases/process_pending_notifications.dart';

class NotificationController extends GetxController {
  final SendQueueOpenedNotifications sendQueueOpenedNotifications;
  final SendPracticeStartedNotifications sendPracticeStartedNotifications;
  final ProcessPendingNotifications processPendingNotifications;

  NotificationController({
    required this.sendQueueOpenedNotifications,
    required this.sendPracticeStartedNotifications,
    required this.processPendingNotifications,
  });

  final RxBool _isProcessing = false.obs;
  final RxString _statusMessage = ''.obs;

  bool get isProcessing => _isProcessing.value;
  String get statusMessage => _statusMessage.value;

  // Send notifications when queue is opened
  Future<void> sendQueueOpenedNotificationsForSchedule(String scheduleId) async {
    try {
      _isProcessing.value = true;
      _statusMessage.value = 'Mengirim notifikasi pembukaan antrean...';
      update();

      await sendQueueOpenedNotifications(scheduleId);

      _statusMessage.value = 'Notifikasi pembukaan antrean berhasil dikirim!';
      Get.snackbar(
        'Berhasil',
        'Notifikasi pembukaan antrean telah dikirim ke semua pasien',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      _statusMessage.value = 'Gagal mengirim notifikasi: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Gagal mengirim notifikasi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      _isProcessing.value = false;
      update();
    }
  }

  // Send notifications when practice starts
  Future<void> sendPracticeStartedNotificationsForSchedule(String scheduleId) async {
    try {
      _isProcessing.value = true;
      _statusMessage.value = 'Mengirim notifikasi dimulainya praktek...';
      update();

      await sendPracticeStartedNotifications(scheduleId);

      _statusMessage.value = 'Notifikasi dimulainya praktek berhasil dikirim!';
      Get.snackbar(
        'Berhasil',
        'Notifikasi dimulainya praktek telah dikirim ke pasien menunggu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      _statusMessage.value = 'Gagal mengirim notifikasi: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Gagal mengirim notifikasi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      _isProcessing.value = false;
      update();
    }
  }

  // Process all pending notifications
  Future<void> processAllPendingNotifications() async {
    try {
      _isProcessing.value = true;
      _statusMessage.value = 'Memproses notifikasi tertunda...';
      update();

      await processPendingNotifications();

      _statusMessage.value = 'Semua notifikasi tertunda berhasil diproses!';
      Get.snackbar(
        'Berhasil',
        'Semua notifikasi tertunda telah diproses',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      _statusMessage.value = 'Gagal memproses notifikasi: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Gagal memproses notifikasi tertunda',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      _isProcessing.value = false;
      update();
    }
  }
}
