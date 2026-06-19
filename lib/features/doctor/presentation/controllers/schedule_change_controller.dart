import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../data/datasources/schedule_change_request_datasource.dart';
import '../../domain/entities/schedule_change_request_entity.dart';

class ScheduleChangeController extends GetxController {
  final ScheduleChangeRequestDatasource _datasource;

  ScheduleChangeController({ScheduleChangeRequestDatasource? datasource})
      : _datasource = datasource ?? ScheduleChangeRequestDatasource();

  // ─── State ─────────────────────────────────────────────────────────────────

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Jadwal aktif dokter
  final RxList<Map<String, dynamic>> activeSchedules =
      <Map<String, dynamic>>[].obs;

  // Riwayat request dokter (stream)
  final RxList<ScheduleChangeRequestEntity> myRequests =
      <ScheduleChangeRequestEntity>[].obs;

  // Form fields
  final RxString selectedScheduleId = ''.obs;
  final RxString selectedScheduleLabel = ''.obs;
  final RxString selectedOldDay = ''.obs;
  final RxString selectedOldStartTime = ''.obs;
  final RxString selectedOldEndTime = ''.obs;

  final RxString newDay = ''.obs;
  final RxString newStartTime = ''.obs;
  final RxString newEndTime = ''.obs;
  final reasonController = TextEditingController();

  // Notifikasi
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;
  final RxInt unreadCount = 0.obs;

  StreamSubscription<List<ScheduleChangeRequestEntity>>? _myRequestsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _notificationsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadActiveSchedules();
    _listenMyRequests();
    _listenNotifications();
  }

  @override
  void onClose() {
    _myRequestsSubscription?.cancel();
    _notificationsSubscription?.cancel();
    reasonController.dispose();
    super.onClose();
  }

  // ─── Load jadwal aktif ────────────────────────────────────────────────────

  Future<void> loadActiveSchedules() async {
    try {
      isLoading.value = true;
      activeSchedules.value = await _datasource.getMyActiveSchedules();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat jadwal: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Stream request saya ──────────────────────────────────────────────────

  void _listenMyRequests() {
    _myRequestsSubscription?.cancel();
    _myRequestsSubscription = _datasource.streamMyRequests().listen(
      (requests) => myRequests.value = requests,
      onError: (e) => debugPrint('Error streaming requests: $e'),
    );
  }

  // ─── Stream notifikasi ────────────────────────────────────────────────────

  void _listenNotifications() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _datasource.streamDoctorNotifications().listen(
      (notifs) {
        notifications.value = notifs;
        unreadCount.value = notifs.where((n) => n['is_read'] == false).length;
      },
      onError: (e) => debugPrint('Error streaming notifications: $e'),
    );
  }

  Future<void> markNotificationRead(String id) async {
    await _datasource.markNotificationRead(id);
  }

  // ─── Pilih jadwal yang akan diubah ────────────────────────────────────────

  void selectSchedule(Map<String, dynamic> schedule) {
    selectedScheduleId.value = schedule['id'] ?? '';
    final days = List<String>.from(schedule['days_of_week'] ?? []);
    selectedOldDay.value = days.isNotEmpty ? days.first : '';
    selectedOldStartTime.value = schedule['start_time'] ?? '';
    selectedOldEndTime.value = schedule['end_time'] ?? '';
    selectedScheduleLabel.value =
        '${days.join(', ')} • ${schedule['start_time']} – ${schedule['end_time']}';

    // Reset new values
    newDay.value = '';
    newStartTime.value = '';
    newEndTime.value = '';
  }

  // ─── Submit request ───────────────────────────────────────────────────────

  Future<void> submitRequest() async {
    if (selectedScheduleId.isEmpty) {
      Get.snackbar('Peringatan', 'Pilih jadwal yang ingin diubah',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newDay.isEmpty) {
      Get.snackbar('Peringatan', 'Pilih hari baru',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newStartTime.isEmpty || newEndTime.isEmpty) {
      Get.snackbar('Peringatan', 'Pilih jam mulai dan jam selesai baru',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (reasonController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Isi alasan perubahan jadwal',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Validasi waktu
    final startParts = newStartTime.value.split(':');
    final endParts = newEndTime.value.split(':');
    final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    if (endMin <= startMin) {
      Get.snackbar('Peringatan', 'Jam selesai harus lebih dari jam mulai',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSubmitting.value = true;

      await _datasource.submitScheduleChangeRequest(
        oldScheduleId: selectedScheduleId.value,
        oldDay: selectedOldDay.value,
        oldStartTime: selectedOldStartTime.value,
        oldEndTime: selectedOldEndTime.value,
        newDay: newDay.value,
        newStartTime: newStartTime.value,
        newEndTime: newEndTime.value,
        reason: reasonController.text.trim(),
      );

      Get.back(); // Tutup form
      Get.snackbar(
        'Berhasil',
        'Permintaan perubahan jadwal berhasil dikirim dan menunggu persetujuan admin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        duration: const Duration(seconds: 4),
      );

      // Reset form
      _resetForm();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    selectedScheduleId.value = '';
    selectedScheduleLabel.value = '';
    selectedOldDay.value = '';
    selectedOldStartTime.value = '';
    selectedOldEndTime.value = '';
    newDay.value = '';
    newStartTime.value = '';
    newEndTime.value = '';
    reasonController.clear();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String formatScheduleLabel(Map<String, dynamic> schedule) {
    final days = List<String>.from(schedule['days_of_week'] ?? []);
    return '${days.join(', ')} • ${schedule['start_time'] ?? ''} – ${schedule['end_time'] ?? ''}';
  }

  String getStatusLabel(ScheduleChangeRequestStatus status) {
    switch (status) {
      case ScheduleChangeRequestStatus.pending:
        return 'Menunggu';
      case ScheduleChangeRequestStatus.approved:
        return 'Disetujui';
      case ScheduleChangeRequestStatus.rejected:
        return 'Ditolak';
    }
  }

  Color getStatusColor(ScheduleChangeRequestStatus status) {
    switch (status) {
      case ScheduleChangeRequestStatus.pending:
        return const Color(0xFFF59E0B);
      case ScheduleChangeRequestStatus.approved:
        return const Color(0xFF10B981);
      case ScheduleChangeRequestStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }
}

// ─── Admin Controller ─────────────────────────────────────────────────────────

class AdminScheduleChangeController extends GetxController {
  final ScheduleChangeRequestDatasource _datasource;

  AdminScheduleChangeController({ScheduleChangeRequestDatasource? datasource})
      : _datasource = datasource ?? ScheduleChangeRequestDatasource();

  final RxList<ScheduleChangeRequestEntity> requests =
      <ScheduleChangeRequestEntity>[].obs;
  final RxString statusFilter = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final rejectionReasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _listenRequests();
  }

  @override
  void onClose() {
    rejectionReasonController.dispose();
    super.onClose();
  }

  void _listenRequests() {
    _datasource
        .streamAllRequests(
          statusFilter:
              statusFilter.value.isEmpty ? null : statusFilter.value,
        )
        .listen(
          (data) => requests.value = data,
          onError: (e) => debugPrint('Error streaming admin requests: $e'),
        );
  }

  void setStatusFilter(String filter) {
    statusFilter.value = filter;
    _listenRequests();
  }

  List<ScheduleChangeRequestEntity> get filteredRequests {
    if (statusFilter.isEmpty) return requests;
    return requests
        .where((r) => r.status.value == statusFilter.value)
        .toList();
  }

  Future<void> approveRequest(String requestId) async {
    try {
      isProcessing.value = true;
      final adminId = FirebaseAuth.instance.currentUser?.uid ?? '';

      await _datasource.approveScheduleChange(
        requestId: requestId,
        adminId: adminId,
      );

      Get.back(); // Tutup dialog detail
      Get.snackbar(
        'Berhasil',
        'Perubahan jadwal telah disetujui dan jadwal baru telah dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        duration: const Duration(seconds: 5),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> rejectRequest(String requestId) async {
    final reason = rejectionReasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar('Peringatan', 'Masukkan alasan penolakan',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isProcessing.value = true;
      final adminId = FirebaseAuth.instance.currentUser?.uid ?? '';

      await _datasource.rejectScheduleChange(
        requestId: requestId,
        adminId: adminId,
        rejectionReason: reason,
      );

      Get.back(); // Tutup dialog reject
      Get.back(); // Tutup dialog detail
      Get.snackbar(
        'Berhasil',
        'Permintaan perubahan jadwal ditolak',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
      );
      rejectionReasonController.clear();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isProcessing.value = false;
    }
  }

  String getStatusLabel(ScheduleChangeRequestStatus status) {
    switch (status) {
      case ScheduleChangeRequestStatus.pending:
        return 'Menunggu';
      case ScheduleChangeRequestStatus.approved:
        return 'Disetujui';
      case ScheduleChangeRequestStatus.rejected:
        return 'Ditolak';
    }
  }

  Color getStatusColor(ScheduleChangeRequestStatus status) {
    switch (status) {
      case ScheduleChangeRequestStatus.pending:
        return const Color(0xFFF59E0B);
      case ScheduleChangeRequestStatus.approved:
        return const Color(0xFF10B981);
      case ScheduleChangeRequestStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }
}
