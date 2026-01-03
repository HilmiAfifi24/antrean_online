import 'package:antrean_online/features/admin/schedule_view/presentation/controllers/schedule_admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SchedulesFilter extends StatelessWidget {
  const SchedulesFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: GetBuilder<ScheduleController>(
        builder: (controller) {
          final doctors = ['Semua', ...controller.doctors.map((d) => d.namaLengkap)];
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctorName = doctors[index];
              final doctorId = index == 0 
                  ? '' 
                  : controller.doctors[index - 1].userId;
              
              final isSelected = index == 0 
                  ? controller.searchController.text.isEmpty && controller.selectedDoctorId.isEmpty
                  : controller.selectedDoctorId == doctorId;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == doctors.length - 1 ? 0 : 12,
                ),
                child: FilterChip(
                  label: Text(doctorName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      if (doctorName == 'Semua') {
                        controller.filterByDoctor('');
                        controller.clearSearch();
                      } else {
                        controller.filterByDoctor(doctorId);
                      }
                    }
                  },
                  selectedColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  checkmarkColor: const Color(0xFF3B82F6),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}