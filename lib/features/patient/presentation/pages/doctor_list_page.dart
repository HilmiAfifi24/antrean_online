import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/doctor_list_controller.dart';
import '../../domain/entities/doctor_entity.dart';

class DoctorListPage extends GetView<DoctorListController> {
  const DoctorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1976D2),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Daftar Dokter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          GetX<DoctorListController>(
            builder: (ctrl) => ctrl.searchText.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: controller.clearSearch,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              isSmallScreen ? 12 : 16,
              16,
              isSmallScreen ? 12 : 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.searchController,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  filled: false,
                  hintText: 'Cari nama dokter atau spesialisasi...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400]!,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF2196F3),
                    size: isSmallScreen ? 20 : 22,
                  ),
                  suffixIcon: GetX<DoctorListController>(
                    builder: (ctrl) => ctrl.searchText.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.grey[400]!,
                              size: isSmallScreen ? 18 : 20,
                            ),
                            onPressed: controller.clearSearch,
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF2196F3),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ),
          ),

          // Doctor Count
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              isSmallScreen ? 12 : 16,
              16,
              isSmallScreen ? 8 : 12,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GetX<DoctorListController>(
                    builder: (ctrl) => Text(
                      '${ctrl.filteredDoctors.length} Dokter Tersedia',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF212121),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Doctor List
          Expanded(
            child: GetX<DoctorListController>(
              builder: (ctrl) {
                if (ctrl.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            color: Color(0xFF2196F3),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Memuat daftar dokter...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600]!,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (ctrl.filteredDoctors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[100]!,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_search_rounded,
                            size: 64,
                            color: Colors.grey[400]!,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tidak ada dokter ditemukan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700]!,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Coba gunakan kata kunci lain',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500]!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadDoctors,
                  color: const Color(0xFF2196F3),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: 8,
                    ),
                    itemCount: ctrl.filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = ctrl.filteredDoctors[index];
                      return _buildDoctorCard(doctor, isSmallScreen);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorEntity doctor, bool isSmall) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.showDoctorDetail(doctor),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmall ? 14 : 16),
            child: Row(
              children: [
                // Doctor Avatar
                Container(
                  width: isSmall ? 56 : 64,
                  height: isSmall ? 56 : 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      doctor.initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmall ? 12 : 16),

                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: isSmall ? 15 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF212121),
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      
                      // Specialization Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          doctor.displaySpecialization,
                          style: TextStyle(
                            fontSize: isSmall ? 11 : 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1976D2),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      
                      if (doctor.phone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: isSmall ? 14 : 15,
                              color: Colors.grey[600]!,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                doctor.phone,
                                style: TextStyle(
                                  fontSize: isSmall ? 12 : 13,
                                  color: Colors.grey[600]!,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: isSmall ? 14 : 16,
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

