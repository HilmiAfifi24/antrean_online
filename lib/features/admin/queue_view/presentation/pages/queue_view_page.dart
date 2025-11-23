import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/queue_view_controller.dart';
import '../widgets/queue_stats_card.dart';
import '../widgets/queue_list_item.dart';
import '../widgets/status_filter_chip.dart';
import '../widgets/custom_date_picker.dart';

class QueueViewPage extends StatelessWidget {
  const QueueViewPage({super.key});

  void _showDatePicker(BuildContext context, QueueViewController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomDatePicker(
        selectedDate: controller.selectedDate,
        onDateSelected: (date) {
          controller.changeSelectedDate(date);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QueueViewController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF3B82F6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  controller.isToday ? 'Antrean Hari Ini' : 'Antrean',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!controller.isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Custom',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              controller.getFormattedDate(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        )),
        actions: [
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: controller.isToday 
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.calendar_month_rounded,
                color: controller.isToday ? Colors.white : const Color(0xFF3B82F6),
                size: 24,
              ),
              onPressed: () => _showDatePicker(context, controller),
              tooltip: 'Pilih Tanggal',
            ),
          )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Obx(() {
          if (controller.isLoading && controller.queues.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: QueueStatsCard(
                              title: 'Menunggu',
                              count: controller.waitingQueues,
                              icon: Icons.schedule_rounded,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QueueStatsCard(
                              title: 'Dipanggil',
                              count: controller.calledQueues,
                              icon: Icons.person_pin_rounded,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: QueueStatsCard(
                              title: 'Selesai',
                              count: controller.completedQueues,
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QueueStatsCard(
                              title: 'Dibatalkan',
                              count: controller.cancelledQueues,
                              icon: Icons.cancel_rounded,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Status Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(() => Row(
                          children: [
                            StatusFilterChip(
                              label: 'Semua',
                              count: controller.totalQueues,
                              isSelected: controller.selectedStatus == 'Semua',
                              onTap: () => controller.changeStatusFilter('Semua'),
                            ),
                            const SizedBox(width: 8),
                            StatusFilterChip(
                              label: 'Menunggu',
                              count: controller.waitingQueues,
                              isSelected: controller.selectedStatus == 'Menunggu',
                              onTap: () => controller.changeStatusFilter('Menunggu'),
                            ),
                            const SizedBox(width: 8),
                            StatusFilterChip(
                              label: 'Dipanggil',
                              count: controller.calledQueues,
                              isSelected: controller.selectedStatus == 'Dipanggil',
                              onTap: () => controller.changeStatusFilter('Dipanggil'),
                            ),
                            const SizedBox(width: 8),
                            StatusFilterChip(
                              label: 'Selesai',
                              count: controller.completedQueues,
                              isSelected: controller.selectedStatus == 'Selesai',
                              onTap: () => controller.changeStatusFilter('Selesai'),
                            ),
                            const SizedBox(width: 8),
                            StatusFilterChip(
                              label: 'Dibatalkan',
                              count: controller.cancelledQueues,
                              isSelected: controller.selectedStatus == 'Dibatalkan',
                              onTap: () => controller.changeStatusFilter('Dibatalkan'),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Queue List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daftar Antrean',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Obx(() => Text(
                            '${controller.filteredQueues.length} pasien',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        if (controller.filteredQueues.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(40),
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
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_rounded,
                                    size: 64,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    controller.selectedStatus == 'Semua'
                                        ? 'Belum ada antrean hari ini'
                                        : 'Tidak ada antrean dengan status ${controller.selectedStatus}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.filteredQueues.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final queue = controller.filteredQueues[index];
                            return QueueListItem(queue: queue);
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
        }),
      ),
    );
  }
}
