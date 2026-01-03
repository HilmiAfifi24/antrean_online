import 'package:antrean_online/features/admin/schedule_view/presentation/controllers/schedule_admin_controller.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/widgets/schedules_filter.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/widgets/schedules_search_bar.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/widgets/empty_schedules_widget.dart';
import 'package:antrean_online/features/admin/schedule_view/presentation/widgets/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SchedulesPage extends StatelessWidget {
  const SchedulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: GetBuilder<ScheduleController>(
        builder: (controller) {
          return Column(
            children: [
              // Modern Header with Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3B82F6),
                      const Color(0xFF2563EB),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kelola Jadwal',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Manajemen jadwal praktek',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Toggle Active/Inactive
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  controller.includeInactive 
                                      ? Icons.visibility_off_rounded 
                                      : Icons.visibility_rounded,
                                  color: Colors.white,
                                ),
                                tooltip: controller.includeInactive 
                                    ? 'Sembunyikan nonaktif'
                                    : 'Tampilkan nonaktif',
                                onPressed: controller.toggleIncludeInactive,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: controller.loadSchedules,
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Statistics Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.event_available_rounded,
                                label: 'Total Jadwal',
                                value: '${controller.getExpandedSchedules().length}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.people_rounded,
                                label: 'Total Pasien',
                                value: '${_getTotalPatients(controller)}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Search & Filter Section
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                color: Colors.white,
                child: Column(
                  children: [
                    const SchedulesSearchBar(),
                    const SizedBox(height: 16),
                    const SchedulesFilter(),
                  ],
                ),
              ),
              
              // Content Section
              Expanded(
                child: controller.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Memuat jadwal...',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : controller.filteredSchedules.isEmpty
                        ? const EmptySchedulesWidget()
                        : RefreshIndicator(
                            onRefresh: controller.loadSchedules,
                            color: const Color(0xFF3B82F6),
                            child: Builder(
                              builder: (context) {
                                final expandedSchedules = controller.getExpandedSchedules();
                                return ListView.builder(
                                  padding: const EdgeInsets.all(20),
                                  itemCount: expandedSchedules.length,
                                  itemBuilder: (context, index) {
                                    final schedule = expandedSchedules[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: ScheduleCard(schedule: schedule),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: GetBuilder<ScheduleController>(
        builder: (controller) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF2563EB),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: controller.showAddScheduleDialog,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text(
                'Tambah Jadwal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalPatients(ScheduleController controller) {
    return controller.getExpandedSchedules().fold<int>(
      0,
      (sum, schedule) => sum + schedule.currentPatients,
    );
  }
}