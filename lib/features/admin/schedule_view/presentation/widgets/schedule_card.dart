import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/controllers/schedule_admin_controller.dart';
import 'package:antrean_online/features/admin/notification/presentation/widgets/notification_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleAdminEntity schedule;

  const ScheduleCard({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: schedule.isActive 
              ? const Color(0xFFE2E8F0) 
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: schedule.isActive ? Colors.white : const Color(0xFFF9FAFB),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.doctorName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: schedule.isActive 
                              ? const Color(0xFF1E293B) 
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        schedule.doctorSpecialization,
                        style: TextStyle(
                          fontSize: 14,
                          color: schedule.isActive 
                              ? const Color(0xFF64748B) 
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: schedule.isActive 
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : const Color(0xFF6B7280).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    schedule.isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: schedule.isActive 
                          ? const Color(0xFF10B981) 
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
                
                // More Menu
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF64748B),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        controller.showEditScheduleDialog(schedule);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, controller);
                        break;
                      case 'activate':
                        controller.activateScheduleById(schedule.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Color(0xFF64748B)),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!schedule.isActive)
                      const PopupMenuItem(
                        value: 'activate',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 18, color: Color(0xFF10B981)),
                            SizedBox(width: 8),
                            Text('Aktifkan'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: schedule.currentPatients > 0 
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hapus',
                            style: TextStyle(
                              color: schedule.currentPatients > 0 
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Schedule Details
            Row(
              children: [
                // Date & Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: schedule.isActive 
                                ? const Color(0xFF64748B) 
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: schedule.isActive 
                                  ? const Color(0xFF374151) 
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: schedule.isActive 
                                ? const Color(0xFF64748B) 
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              schedule.daysOfWeek.first,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: schedule.isActive 
                                    ? const Color(0xFF64748B) 
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Patient Count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${schedule.currentPatients}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'dari ${schedule.maxPatients}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const Text(
                        'Pasien',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kapasitas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((schedule.currentPatients / schedule.maxPatients) * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: schedule.currentPatients / schedule.maxPatients,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    schedule.currentPatients / schedule.maxPatients >= 0.8
                        ? const Color(0xFFEF4444)
                        : schedule.currentPatients / schedule.maxPatients >= 0.6
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            
            // Notification Buttons (only show if schedule is active)
            if (schedule.isActive)
              NotificationButtons(
                scheduleId: schedule.id,
                doctorName: schedule.doctorName,
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showDeleteConfirmation(BuildContext context, ScheduleController controller) {
    if (schedule.currentPatients > 0) {
      Get.snackbar(
        'Tidak Dapat Menghapus',
        'Jadwal ini masih memiliki ${schedule.currentPatients} pasien aktif',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal ${schedule.doctorName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteScheduleById(schedule.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}