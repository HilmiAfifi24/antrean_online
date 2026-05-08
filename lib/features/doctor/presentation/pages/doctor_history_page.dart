import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/doctor_history_controller.dart';
import '../widgets/queue_card.dart';

class DoctorHistoryPage extends StatelessWidget {
  const DoctorHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorHistoryController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

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
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Riwayat Pemeriksaan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, d MMMM y', 'id_ID').format(controller.selectedDate),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: controller.refreshData,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.error.value.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(
                                controller.error.value,
                                style: TextStyle(color: Colors.red[700]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: controller.refreshData,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (controller.completedQueues.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada pasien selesai pada tanggal ini',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => controller.refreshData(),
                        child: ListView.builder(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          itemCount: controller.completedQueues.length,
                          itemBuilder: (context, index) {
                            final queue = controller.completedQueues[index];
                            return QueueCard(
                              queueNumber: queue.queueNumber,
                              patientName: queue.patientName,
                              complaint: queue.complaint,
                              status: queue.status,
                            );
                          },
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
}
