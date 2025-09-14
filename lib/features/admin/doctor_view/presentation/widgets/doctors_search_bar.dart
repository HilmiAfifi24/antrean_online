import 'package:antrean_online/features/admin/doctor_view/presentation/controllers/doctor_admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorsSearchBar extends StatelessWidget {
  const DoctorsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller.searchController,
            onChanged: (query) {
              controller.filterDoctors(query);
            },
            decoration: InputDecoration(
              hintText: 'Cari dokter...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: controller.isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.search,
                      color: Color(0xFF64748B),
                    ),
              suffixIcon: controller.searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: controller.clearSearch,
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF64748B),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        );
      },
    );
  }
}