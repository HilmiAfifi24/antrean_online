import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/repositories/patient_queue_repository.dart';
import '../controllers/queue_controller.dart';
import '../../../../core/routes/app_routes.dart';

/// Dedicated controller for a single queue's realtime data.
/// Created fresh per navigation so each detail page has its own streams.
class QueueDetailController extends GetxController {
  final PatientQueueRepository repository;
  final QueueEntity initialQueue;

  QueueDetailController({
    required this.repository,
    required this.initialQueue,
  });

  // Reactive state
  final Rx<QueueEntity?> _queue = Rx<QueueEntity?>(null);
  final RxnInt _currentClinicQueueNumber = RxnInt();
  final RxInt _waitingAheadCount = 0.obs;
  final RxBool _isLoading = false.obs;

  // Streams
  StreamSubscription? _queueSubscription;
  StreamSubscription? _clinicQueueSubscription;
  StreamSubscription? _waitingCountSubscription;

  // Getters
  QueueEntity? get queue => _queue.value;
  int? get currentClinicQueueNumber => _currentClinicQueueNumber.value;
  int get waitingAheadCount => _waitingAheadCount.value;
  bool get isLoading => _isLoading.value;

  bool get isPatientInClinic {
    final q = _queue.value;
    final current = _currentClinicQueueNumber.value;
    if (q == null || current == null) return false;
    return q.queueNumber <= current;
  }

  int get remainingPatientsBeforeYou {
    final q = _queue.value;
    if (q == null) return 0;
    final current = _currentClinicQueueNumber.value;
    if (current == null) {
      final v = _waitingAheadCount.value;
      return v < 0 ? 0 : v;
    }
    if (q.queueNumber <= current) return 0;
    final remaining = _waitingAheadCount.value - 1;
    return remaining > 0 ? remaining : 0;
  }

  String get queueProgressLabel {
    final q = _queue.value;
    if (q == null) return '';
    if (q.status == 'selesai' || q.status == 'completed') {
      return 'Pemeriksaan selesai';
    }
    if (q.status == 'dibatalkan' ||
        q.status == 'cancelled_by_patient' ||
        q.status == 'cancelled_by_doctor') {
      return 'Antrean dibatalkan';
    }
    if (q.status == 'dipanggil' || isPatientInClinic) {
      return 'Anda sedang di dalam klinik';
    }
    final remaining = remainingPatientsBeforeYou;
    if (remaining == 0) return 'Anda berikutnya!';
    return 'Sisa $remaining orang sebelum Anda';
  }

  @override
  void onInit() {
    super.onInit();
    _queue.value = initialQueue;
    _startStreams();
  }

  @override
  void onClose() {
    _queueSubscription?.cancel();
    _clinicQueueSubscription?.cancel();
    _waitingCountSubscription?.cancel();
    super.onClose();
  }

  void _startStreams() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Watch this specific patient's active queues and find the matching one
    _queueSubscription = repository.watchActiveQueues(userId).listen((queues) {
      final match = queues.where((q) => q.id == initialQueue.id).firstOrNull;
      if (match != null) {
        _queue.value = match;
      }
      // If no match found in active queues, keep the last known state
      // (it might have been completed/cancelled)
    });

    final normalizedDate = DateTime(
      initialQueue.appointmentDate.year,
      initialQueue.appointmentDate.month,
      initialQueue.appointmentDate.day,
    );

    // Watch current clinic queue number
    _clinicQueueSubscription = repository
        .watchCurrentClinicQueueNumber(
          scheduleId: initialQueue.scheduleId,
          appointmentDate: normalizedDate,
        )
        .listen((clinicNum) => _currentClinicQueueNumber.value = clinicNum);

    // Watch waiting count
    _waitingCountSubscription = repository
        .watchWaitingCountBeforeQueue(
          scheduleId: initialQueue.scheduleId,
          appointmentDate: normalizedDate,
          queueNumber: initialQueue.queueNumber,
        )
        .listen((count) => _waitingAheadCount.value = count);
  }

  Future<void> cancelQueue() async {
    final q = _queue.value;
    if (q == null) return;

    final queueController = Get.find<QueueController>();
    await queueController.cancelQueue(q);

    // Navigate back after cancellation
    if (q.status == 'dibatalkan' || !q.isActive) {
      Get.back();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class QueueDetailPage extends StatefulWidget {
  const QueueDetailPage({super.key});

  @override
  State<QueueDetailPage> createState() => _QueueDetailPageState();
}

class _QueueDetailPageState extends State<QueueDetailPage>
    with SingleTickerProviderStateMixin {
  late QueueDetailController _controller;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    final queue = Get.arguments as QueueEntity;
    final repo = Get.find<PatientQueueRepository>();

    // Use a unique tag based on queue id so multiple detail pages don't clash
    _controller = Get.put(
      QueueDetailController(repository: repo, initialQueue: queue),
      tag: queue.id,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // Delete the tagged controller so it's GC'd
    Get.delete<QueueDetailController>(tag: _controller.initialQueue.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Obx(() {
                      final queue = _controller.queue;
                      if (queue == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                        child: Column(
                          children: [
                            _buildClinicStatusCard(queue),
                            const SizedBox(height: 16),
                            _buildQueueNumberCard(queue),
                            const SizedBox(height: 16),
                            _buildDoctorInfoCard(queue),
                            const SizedBox(height: 16),
                            _buildAppointmentInfoCard(queue),
                            if (queue.complaint.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildComplaintCard(queue),
                            ],
                            if (queue.canRequestReschedule) ...[
                              const SizedBox(height: 24),
                              _buildActionButtons(queue),
                            ],
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 16,
        bottom: 20,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Antrean Saya',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // History shortcut
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.queueHistory),
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            tooltip: 'Riwayat Antrean',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Clinic Status Card ───────────────────────────────────────────────────

  Widget _buildClinicStatusCard(QueueEntity queue) {
    final isActive = queue.isActive;
    final clinicNum = _controller.currentClinicQueueNumber;

    Color cardColor;
    IconData statusIcon;
    String titleText;
    String subtitleText;

    if (!isActive) {
      cardColor = queue.status == 'selesai' || queue.status == 'completed'
          ? const Color(0xFF43A047)
          : Colors.grey;
      statusIcon = queue.status == 'selesai' || queue.status == 'completed'
          ? Icons.check_circle_rounded
          : Icons.cancel_rounded;
      titleText = queue.status == 'selesai' || queue.status == 'completed'
          ? 'Pemeriksaan Selesai'
          : 'Antrean Dibatalkan';
      subtitleText = queue.status == 'selesai' || queue.status == 'completed'
          ? 'Terima kasih telah menggunakan layanan kami'
          : queue.cancellationReason ?? 'Antrean ini telah dibatalkan';
    } else if (_controller.isPatientInClinic ||
        queue.status == 'dipanggil') {
      cardColor = const Color(0xFF00897B);
      statusIcon = Icons.local_hospital_rounded;
      titleText = 'Antrean Saat Ini di Klinik';
      subtitleText = 'Anda sedang dipanggil masuk klinik';
    } else {
      cardColor = const Color(0xFF1976D2);
      statusIcon = Icons.schedule_rounded;
      titleText = 'Antrean Saat Ini di Klinik';
      subtitleText = clinicNum != null
          ? 'Nomor yang sedang dilayani: ${clinicNum.toString().padLeft(3, '0')}'
          : 'Belum ada yang dipanggil';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor,
            cardColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) => Transform.scale(
              scale: isActive ? _pulseAnimation.value : 1.0,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
                if (isActive && !_controller.isPatientInClinic) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(
                      () => Text(
                        _controller.queueProgressLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Queue Number Card ────────────────────────────────────────────────────

  Widget _buildQueueNumberCard(QueueEntity queue) {
    final statusColor = _statusColor(queue.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Nomor Antrean Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          // Big number
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) => Transform.scale(
              scale: queue.status == 'dipanggil'
                  ? _pulseAnimation.value
                  : 1.0,
              child: child,
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  queue.queueNumber.toString().padLeft(3, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Status chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: statusColor.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon(queue.status),
                    color: statusColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  queue.statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (queue.status == 'menunggu' ||
              queue.status == 'waiting' ||
              queue.status == 'rescheduled') ...[
            const SizedBox(height: 12),
            Obx(
              () => Text(
                _controller.queueProgressLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Doctor Info Card ─────────────────────────────────────────────────────

  Widget _buildDoctorInfoCard(QueueEntity queue) {
    return _buildInfoCard(
      title: 'Informasi Dokter',
      icon: Icons.local_hospital_rounded,
      iconColor: const Color(0xFF1976D2),
      children: [
        _buildInfoRow(
          icon: Icons.person_rounded,
          label: 'Dokter',
          value: queue.doctorName,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.medical_services_rounded,
          label: 'Spesialisasi',
          value: queue.doctorSpecialization,
        ),
      ],
    );
  }

  // ─── Appointment Info Card ────────────────────────────────────────────────

  Widget _buildAppointmentInfoCard(QueueEntity queue) {
    return _buildInfoCard(
      title: 'Informasi Janji Temu',
      icon: Icons.event_note_rounded,
      iconColor: const Color(0xFF7B1FA2),
      children: [
        _buildInfoRow(
          icon: Icons.calendar_today_rounded,
          label: 'Tanggal',
          value: queue.formattedDate,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.access_time_rounded,
          label: 'Waktu',
          value: queue.appointmentTime,
        ),
      ],
    );
  }

  // ─── Complaint Card ───────────────────────────────────────────────────────

  Widget _buildComplaintCard(QueueEntity queue) {
    return _buildInfoCard(
      title: 'Keluhan',
      icon: Icons.note_alt_rounded,
      iconColor: const Color(0xFFE65100),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote_rounded,
                color: Colors.grey[400], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                queue.complaint,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Action Buttons ───────────────────────────────────────────────────────

  Widget _buildActionButtons(QueueEntity queue) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () =>
                Get.toNamed(AppRoutes.patientReschedule, arguments: queue),
            icon: const Icon(Icons.edit_calendar_rounded, size: 18),
            label: const Text(
              'Reschedule',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        if (queue.status == 'menunggu' || queue.status == 'waiting') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final queueController = Get.find<QueueController>();
                final q = _controller.queue;
                if (q == null) return;
                await queueController.cancelQueue(q);
                if (_controller.queue?.status == 'dibatalkan' ||
                    _controller.queue?.status == 'cancelled_by_patient' ||
                    !(_controller.queue?.isActive ?? false)) {
                  Get.back();
                }
              },
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text(
                'Batalkan Antrean',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Shared Widgets ───────────────────────────────────────────────────────

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'menunggu':
      case 'waiting':
        return Colors.blue;
      case 'dipanggil':
      case 'ongoing':
        return Colors.green;
      case 'selesai':
      case 'completed':
        return Colors.grey;
      case 'dibatalkan':
      case 'cancelled_by_patient':
      case 'cancelled_by_doctor':
        return Colors.red;
      case 'rescheduled':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'menunggu':
      case 'waiting':
        return Icons.hourglass_top_rounded;
      case 'dipanggil':
      case 'ongoing':
        return Icons.campaign_rounded;
      case 'selesai':
      case 'completed':
        return Icons.check_circle_rounded;
      case 'dibatalkan':
      case 'cancelled_by_patient':
      case 'cancelled_by_doctor':
        return Icons.cancel_rounded;
      case 'rescheduled':
        return Icons.edit_calendar_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
