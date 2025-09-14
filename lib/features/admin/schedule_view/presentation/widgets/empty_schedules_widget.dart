import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/schedule_admin_controller.dart';

class EmptySchedulesWidget extends StatelessWidget {
  const EmptySchedulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleController>(
      builder: (controller) {
        final hasSearchOrFilter = controller.searchController.text.isNotEmpty || 
                                 controller.selectedDoctorId.isNotEmpty;
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.schedule_outlined,
                    size: 60,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  hasSearchOrFilter
                      ? 'Jadwal Tidak Ditemukan'
                      : 'Belum Ada Jadwal',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  hasSearchOrFilter
                      ? 'Coba ubah kata kunci pencarian atau filter'
                      : 'Tambahkan jadwal pertama untuk memulai',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                if (hasSearchOrFilter)
                  OutlinedButton.icon(
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text('Hapus Filter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: controller.showAddScheduleDialog,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah Jadwal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}