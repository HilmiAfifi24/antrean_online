import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationButtons extends StatelessWidget {
  final String scheduleId;
  final String doctorName;

  const NotificationButtons({
    super.key,
    required this.scheduleId,
    required this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      init: Get.find<NotificationController>(),
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Kirim Notifikasi WhatsApp',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Status message
              if (controller.statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: controller.isProcessing 
                      ? Colors.blue.shade50 
                      : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.isProcessing 
                        ? Colors.blue.shade200 
                        : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.isProcessing 
                          ? Icons.hourglass_top 
                          : Icons.check_circle,
                        color: controller.isProcessing 
                          ? Colors.blue.shade600 
                          : Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.statusMessage,
                          style: TextStyle(
                            color: controller.isProcessing 
                              ? Colors.blue.shade800 
                              : Colors.green.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.isProcessing
                        ? null
                        : () => _showConfirmDialog(
                              context,
                              'Buka Antrean',
                              'Kirim notifikasi pembukaan antrean ke semua pasien yang sudah booking untuk jadwal Dr. $doctorName?',
                              () => controller.sendQueueOpenedNotificationsForSchedule(scheduleId),
                            ),
                      icon: const Icon(Icons.queue, size: 16),
                      label: const Text('Buka Antrean', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.isProcessing
                        ? null
                        : () => _showConfirmDialog(
                              context,
                              'Mulai Praktek',
                              'Kirim notifikasi praktek dimulai ke pasien yang sedang menunggu untuk jadwal Dr. $doctorName?',
                              () => controller.sendPracticeStartedNotificationsForSchedule(scheduleId),
                            ),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Mulai Praktek', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.send,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }
}
