// features/admin/doctors/presentation/pages/doctors_page.dart
import 'package:antrean_online/features/admin/doctor_view/presentation/controllers/doctor_admin_controller.dart';
import 'package:antrean_online/features/admin/doctor_view/presentation/widgets/doctor_card.dart';
import 'package:antrean_online/features/admin/doctor_view/presentation/widgets/doctors_header.dart';
import 'package:antrean_online/features/admin/doctor_view/presentation/widgets/doctors_search_bar.dart';
import 'package:antrean_online/features/admin/doctor_view/presentation/widgets/empty_doctors_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorsPage extends StatelessWidget {
  const DoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorAdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header with gradient
          const DoctorsHeader(),

          // Search and Filter Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            color: Colors.white,
            child: Column(
              children: [
                const DoctorsSearchBar(),
                const SizedBox(height: 16),
                // const DoctorsFilter(),
              ],
            ),
          ),

          // Doctors List
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshData,
              color: const Color(0xFF3B82F6),
              child: GetBuilder<DoctorAdminController>(
                builder: (controller) {
                  if (controller.isLoading && controller.doctors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3B82F6),
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Memuat data dokter...',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredDoctors.isEmpty) {
                    return const EmptyDoctorsWidget();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: controller.filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = controller.filteredDoctors[index];
                      return DoctorCard(
                        doctor: doctor,
                        onEdit: () => controller.showEditDoctorDialog(doctor),
                        onDelete: () => controller.removeDoctor(
                          doctor.id,
                          doctor.namaLengkap,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
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
          onPressed: controller.showAddDoctorDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text(
            'Tambah Dokter',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
