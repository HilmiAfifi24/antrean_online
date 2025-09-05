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
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      icon: Icons.people_outline_rounded,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Aksi Cepat",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Quick Action Buttons Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildQuickActionCard(
                          title: "Tambah Dokter",
                          icon: Icons.person_add_alt_1_rounded,
                          color: const Color(0xFF10B981),
                          onTap: () => Get.toNamed("/admin/add-doctor"),
                        ),
                        _buildQuickActionCard(
                          title: "Kelola Jadwal",
                          icon: Icons.calendar_today_rounded,
                          color: const Color(0xFF8B5CF6),
                          onTap: () => Get.toNamed("/admin/manage-schedules"),
                        ),
                        _buildQuickActionCard(
                          title: "Lihat Laporan",
                          icon: Icons.analytics_rounded,
                          color: const Color(0xFFF59E0B),
                          onTap: () => Get.toNamed("/admin/reports"),
                        ),
                        _buildQuickActionCard(
                          title: "Pengaturan",
                          icon: Icons.settings_rounded,
                          color: const Color(0xFF6B7280),
                          onTap: () => Get.toNamed("/admin/settings"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Activities Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Aktivitas Terbaru",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed("/admin/activities"),
                          child: const Text(
                            "Lihat Semua",
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Recent Activity Items
                    Obx(() {
                      if (controller.recentActivities.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  size: 48,
                                  color: Color(0xFF94A3B8),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Belum ada aktivitas terbaru",
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.recentActivities.length,
                        itemBuilder: (context, index) {
                          final activity = controller.recentActivities[index];
                          return _buildActivityItem(
                            title: activity['title'],
                            subtitle: activity['subtitle'],
                            time: activity['time'],
                            icon: _getActivityIcon(activity['type']),
                            color: _getActivityColor(activity['type']),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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