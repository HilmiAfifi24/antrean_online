import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../controllers/queue_controller.dart';

class PatientReschedulePage extends StatefulWidget {
  const PatientReschedulePage({super.key});

  @override
  State<PatientReschedulePage> createState() => _PatientReschedulePageState();
}

class _PatientReschedulePageState extends State<PatientReschedulePage> {
  late final QueueEntity queue;
  late final QueueController controller;

  @override
  void initState() {
    super.initState();
    queue = Get.arguments as QueueEntity;
    controller = Get.find<QueueController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAvailableRescheduleDates(queue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: const Text('Pilih Jadwal Baru'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading && controller.availableRescheduleDates.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.availableRescheduleDates.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildCurrentQueueCard(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemBuilder: (context, index) {
                  final schedule = controller.availableRescheduleDates[index];
                  return _buildScheduleTile(schedule);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: controller.availableRescheduleDates.length,
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Obx(
          () => ElevatedButton.icon(
            onPressed: controller.isLoading
                ? null
                : () async {
                    final success = await controller.rescheduleQueue(queue);
                    if (success) {
                      Get.until((route) {
                        return route.settings.name == AppRoutes.queue ||
                            route.settings.name == AppRoutes.pasien ||
                            route.isFirst;
                      });
                    }
                  },
            icon: controller.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.event_available_rounded),
            label: const Text(
              'Konfirmasi Reschedule',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentQueueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1976D2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            queue.doctorName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${queue.formattedDate} • ${queue.appointmentTime}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTile(ScheduleEntity schedule) {
    final selected = controller.selectedRescheduleSchedule;
    final isSelected = selected?.id == schedule.id &&
        selected?.date.year == schedule.date.year &&
        selected?.date.month == schedule.date.month &&
        selected?.date.day == schedule.date.day;

    return InkWell(
      onTap: () => controller.selectRescheduleDate(schedule),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${schedule.date.day}',
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(schedule.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule.getTimeRange(),
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Slot tersedia: ${schedule.availableSlots} dari ${schedule.maxPatients}',
                    style: TextStyle(
                      color: schedule.availableSlots > 0
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada jadwal tersedia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua slot dokter ini penuh atau belum ada jadwal aktif.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
