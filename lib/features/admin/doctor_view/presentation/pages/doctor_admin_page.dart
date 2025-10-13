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
    final controller = Get.find<DoctorController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const DoctorsHeader(),
            
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(20),
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
                child: GetBuilder<DoctorController>(
                  builder: (controller) {
                    if (controller.isLoading && controller.doctors.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      );
                    }

                    if (controller.filteredDoctors.isEmpty) {
                      return const EmptyDoctorsWidget();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = controller.filteredDoctors[index];
                        return DoctorCard(
                          doctor: doctor,
                          onEdit: () => controller.showEditDoctorDialog(doctor),
                          onDelete: () => controller.removeDoctor(doctor.id, doctor.namaLengkap),
                          // onToggleStatus: () => controller.toggleDoctorStatus(doctor.id, doctor.isActive),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showAddDoctorDialog,
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Dokter',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}