// pages/admin_home_page.dart
import 'package:antrean_online/features/admin/home/presentation/widgets/dashboard_stats_card.dart';
import 'package:antrean_online/features/admin/home/presentation/widgets/home_admin_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<AdminController>(
          builder: (controller) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with greeting and profile
                  const AdminHeader(),
                  
                  const SizedBox(height: 24),

                  // Page Title
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Statistics Cards
                  Column(
                    children: [
                      Obx(() {
                        return DashboardStatCard(
                          title: "Total Pasien",
                          count: controller.totalPasien.value,
                          icon: Icons.people_outlined,
                          color: const Color(0xFF3B82F6),
                          onTap: () => Get.toNamed("/admin/patients"),
                        );
                      }),

                      const SizedBox(height: 16),

                      Obx(() {
                        return DashboardStatCard(
                          title: "Total Dokter",
                          count: controller.totalDokter.value,
                          icon: Icons.medical_services_outlined,
                          color: const Color(0xFF10B981),
                          onTap: () => Get.toNamed("/admin/doctors"),
                        );
                      }),

                      const SizedBox(height: 16),

                      Obx(() {
                        return DashboardStatCard(
                          title: "Total Jadwal",
                          count: controller.totalJadwal.value,
                          icon: Icons.schedule_outlined,
                          color: const Color(0xFF8B5CF6),
                          onTap: () => Get.toNamed("/admin/schedules"),
                        );
                      }),

                      const SizedBox(height: 16),

                      Obx(() {
                        return DashboardStatCard(
                          title: "Total Antrean",
                          count: controller.totalAntrean.value,
                          icon: Icons.queue_outlined,
                          color: const Color(0xFFF59E0B),
                          onTap: () => Get.toNamed("/admin/queues"),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions Section
                  const Text(
                    "Aksi Cepat",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          title: "Tambah Dokter",
                          icon: Icons.person_add_rounded,
                          color: const Color(0xFF10B981),
                          onTap: () {
                            Get.toNamed("/admin/doctors");
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionCard(
                          title: "Kelola Jadwal",
                          icon: Icons.schedule_rounded,
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            Get.toNamed("/admin/schedules");
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent Activities Section
                  const Text(
                    "Aktivitas Terbaru",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF64748B).withValues(alpha: 0.06),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: const Color(0xFF64748B),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Riwayat Aktivitas",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (controller.recentActivities.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_rounded,
                                    size: 48,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Belum ada aktivitas",
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.recentActivities.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            itemBuilder: (context, index) {
                              final activity = controller.recentActivities[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getActivityColor(activity['type'])
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getActivityIcon(activity['type']),
                                    size: 20,
                                    color: _getActivityColor(activity['type']),
                                  ),
                                ),
                                title: Text(
                                  activity['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  activity['subtitle'],
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Text(
                                  activity['time'],
                                  style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'user_registered':
        return Icons.person_add_rounded;
      case 'appointment_created':
        return Icons.event_rounded;
      case 'doctor_added':
        return Icons.medical_services_rounded;
      case 'schedule_updated':
        return Icons.schedule_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'user_registered':
        return const Color(0xFF10B981);
      case 'appointment_created':
        return const Color(0xFF3B82F6);
      case 'doctor_added':
        return const Color(0xFF8B5CF6);
      case 'schedule_updated':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}