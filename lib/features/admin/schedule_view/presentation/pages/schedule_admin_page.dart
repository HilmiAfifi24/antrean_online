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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Kelola Jadwal',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B)),
          onPressed: () => Get.back(),
        ),
        actions: [
          GetBuilder<ScheduleController>(
            builder: (controller) {
              return IconButton(
                icon: Icon(
                  controller.includeInactive 
                      ? Icons.visibility_off 
                      : Icons.visibility,
                  color: const Color(0xFF64748B),
                ),
                tooltip: controller.includeInactive 
                    ? 'Sembunyikan jadwal nonaktif'
                    : 'Tampilkan jadwal nonaktif',
                onPressed: controller.toggleIncludeInactive,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GetBuilder<ScheduleController>(
        builder: (controller) {
          return Column(
            children: [
              // Header Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    const SchedulesSearchBar(),
                    
                    const SizedBox(height: 16),
                    
                    // Filter Section
                    const SchedulesFilter(),
                    
                    const SizedBox(height: 16),
                    
                    // Stats & Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.getExpandedSchedules().length} Jadwal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            if (controller.includeInactive)
                              Text(
                                'Termasuk jadwal nonaktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: controller.showAddScheduleDialog,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Tambah Jadwal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Content Section
              Expanded(
                child: controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
                      )
                    : controller.filteredSchedules.isEmpty
                        ? const EmptySchedulesWidget()
                        : RefreshIndicator(
                            onRefresh: controller.loadSchedules,
                            child: Builder(
                              builder: (context) {
                                final expandedSchedules = controller.getExpandedSchedules();
                                return ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: expandedSchedules.length,
                                  itemBuilder: (context, index) {
                                    final schedule = expandedSchedules[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
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
    );
  }
}