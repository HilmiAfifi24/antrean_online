import 'package:antrean_online/features/admin/doctor_view/presentation/controllers/doctor_admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorsSearchBar extends StatelessWidget {
  const DoctorsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorAdminController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFF8FAFC), Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller.searchController,
            onChanged: (query) {
              controller.filterDoctors(query);
            },
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Cari nama dokter, spesialisasi, atau ID...',
              hintStyle: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
              ),
              prefixIcon: controller.isSearching
                  ? Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.search_rounded,
                        color: const Color(0xFF3B82F6),
                        size: 24,
                      ),
                    ),
              suffixIcon: controller.searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: controller.clearSearch,
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
