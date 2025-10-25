import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/queue_controller.dart';

// Track whether we've already shown the index-building snackbar to avoid spamming users
bool _indexSnackbarShown = false;

class QueuePage extends GetView<QueueController> {
  const QueuePage({super.key});

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
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Custom AppBar
                _buildAppBar(context),
                // Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Obx(() {
                      if (controller.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (controller.hasActiveQueue) {
                        return _buildActiveQueueView();
                      } else {
                        return _buildEmptyQueueView();
                      }
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Antrean Saya',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueueView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada Antrean',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Anda belum memiliki antrean\njanji temu dengan dokter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/patient/select-schedule'),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Daftar Antrean'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveQueueView() {
    final queue = controller.activeQueue!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Queue in Clinic Card (Realtime)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('queues')
                .where('schedule_id', isEqualTo: queue.scheduleId)
                .where('status', isEqualTo: 'dipanggil')
                .orderBy('queue_number', descending: false)
                .limit(1)
                .snapshots()
                .handleError((error) {
              // Log error and let builder show friendly UI
              // ignore: avoid_print
              print('[QueuePage] currentQueue stream error: $error');
            }),
            builder: (context, snapshot) {
              int? currentQueueNumber;
              if (snapshot.hasError) {
                
                // print('[QueuePage] currentQueue snapshot error: ${snapshot.error}');
                if (!_indexSnackbarShown && snapshot.error.toString().contains('requires an index')) {
                  _indexSnackbarShown = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    try {
                      Get.snackbar(
                        'Sinkronisasi',
                        'Data sedang disinkronkan. Mohon tunggu beberapa saat sampai Firestore membangun indeks.',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 4),
                      );
                    } catch (_) {}
                  });
                }
              }

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final doc = snapshot.data!.docs.first;
                currentQueueNumber = doc['queue_number'] as int?;
              }
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Antrean Saat Ini di Klinik',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (currentQueueNumber != null)
                      Text(
                        currentQueueNumber.toString().padLeft(3, '0'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      )
                    else
                      Text(
                        '---',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 4,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      currentQueueNumber != null 
                          ? 'Sedang dilayani' 
                          : 'Belum ada yang dipanggil',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Queue Number Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Nomor Antrean Anda',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  queue.queueNumber.toString().padLeft(3, '0'),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Estimated waiting info
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('queues')
                      .where('schedule_id', isEqualTo: queue.scheduleId)
                      .where('status', whereIn: ['menunggu', 'dipanggil'])
                      .where('queue_number', isLessThan: queue.queueNumber)
                      .snapshots()
                      .handleError((error) {
                    // ignore: avoid_print
                    print('[QueuePage] waitingCount stream error: $error');
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      // ignore: avoid_print
                      print('[QueuePage] waitingCount snapshot error: ${snapshot.error}');
                      if (!_indexSnackbarShown && snapshot.error.toString().contains('requires an index')) {
                        _indexSnackbarShown = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          try {
                            Get.snackbar(
                              'Sinkronisasi',
                              'Data sedang disinkronkan. Mohon tunggu beberapa saat sampai Firestore membangun indeks.',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 4),
                            );
                          } catch (_) {}
                        });
                      }
                      return const SizedBox.shrink();
                    }

                    if (snapshot.hasData) {
                      final waitingCount = snapshot.data!.docs.length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              waitingCount == 0
                                  ? 'Anda berikutnya!'
                                  : 'Sisa $waitingCount orang sebelum Anda',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(queue.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    queue.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Doctor Info Card
          _buildInfoCard(
            title: 'Informasi Dokter',
            children: [
              _buildInfoRow(Icons.person, 'Dokter', queue.doctorName),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.medical_services, 'Spesialisasi', 
                  queue.doctorSpecialization),
            ],
          ),
          const SizedBox(height: 16),
          
          // Appointment Info Card
          _buildInfoCard(
            title: 'Informasi Janji Temu',
            children: [
              _buildInfoRow(Icons.calendar_today, 'Tanggal', 
                  queue.formattedDate),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.access_time, 'Waktu', 
                  queue.appointmentTime),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.note_alt, 'Keluhan', 
                  queue.complaint),
            ],
          ),
          const SizedBox(height: 24),
          
          // Cancel Button (only if status is 'menunggu')
          if (queue.status == 'menunggu')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => controller.cancelQueue(),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Batalkan Antrean'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu':
        return Colors.blue;
      case 'dipanggil':
        return Colors.green;
      case 'selesai':
        return Colors.grey;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
