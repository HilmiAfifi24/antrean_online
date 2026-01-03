// pages/admin_home_page.dart
import 'package:antrean_online/core/routes/app_routes.dart';
import 'package:antrean_online/features/admin/home/presentation/widgets/dashboard_stats_card.dart';
import 'package:antrean_online/features/admin/home/presentation/widgets/home_admin_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> with RouteAware {
  @override
  void initState() {
    super.initState();
    // Refresh data saat pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AdminController>().loadDashboardData();
    });
  }

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
                          onTap: () => Get.toNamed(AppRoutes.adminPatientList),
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
                          onTap: () => Get.toNamed(AppRoutes.adminQueues),
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          const Color(0xFF3B82F6).withValues(alpha: 0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF3B82F6).withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                      const Color(0xFF3B82F6).withValues(alpha: 0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.history_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Riwayat Aktivitas",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
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
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                          const Color(0xFF3B82F6).withValues(alpha: 0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.inbox_rounded,
                                      size: 48,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Belum ada aktivitas",
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
                            separatorBuilder: (context, index) => Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final activity = controller.recentActivities[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getActivityColor(activity['type']).withValues(alpha: 0.15),
                                            _getActivityColor(activity['type']).withValues(alpha: 0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _getActivityColor(activity['type']).withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        _getActivityIcon(activity['type']),
                                        size: 22,
                                        color: _getActivityColor(activity['type']),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            activity['subtitle'],
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        controller.formatActivityTime(activity['timestamp']),
                                        style: const TextStyle(
                                          color: Color(0xFF3B82F6),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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