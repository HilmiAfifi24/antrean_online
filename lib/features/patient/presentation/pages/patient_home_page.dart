import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../controllers/patient_controller.dart';
import '../../domain/entities/schedule_entity.dart';

class PatientHomePage extends GetView<PatientController> {
  const PatientHomePage({super.key});

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
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.loadPatientName();
              await controller.refreshData();
            },
            color: const Color(0xFF2196F3),
            child: CustomScrollView(
              slivers: [
              // Header Section with Gradient
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + (isSmallScreen ? 16 : 24),
                    20,
                    isSmallScreen ? 20 : 28,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x331976D2),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Text(
                        controller.greeting,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      
                      // Patient Name
                      GetX<PatientController>(
                        builder: (controller) => Text(
                          controller.patientName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 26 : 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      
                      // Subtitle
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: isSmallScreen ? 14 : 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Semoga anda lekas sembuh',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isSmallScreen ? 13 : 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      
                      // Search Bar
                      Container(
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
                          onChanged: controller.performSearch,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            filled: false,
                            hintText: 'Cari Dokter',
                            hintStyle: TextStyle(
                              color: Colors.grey[400]!,
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: const Color(0xFF2196F3),
                              size: isSmallScreen ? 20 : 22,
                            ),
                            suffixIcon: GetX<PatientController>(
                              builder: (ctrl) => ctrl.searchText.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: Colors.grey[400]!,
                                        size: isSmallScreen ? 18 : 20,
                                      ),
                                      onPressed: () {
                                        controller.searchController.clear();
                                        controller.performSearch('');
                                      },
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
                    ],
                  ),
                ),
              ),

              // Action Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    isSmallScreen ? 16 : 20,
                    16,
                    isSmallScreen ? 12 : 16,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final buttonWidth = (constraints.maxWidth - 32) / 3;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionButton(
                            icon: Icons.receipt_long_rounded,
                            label: 'Antrean\nSaya',
                            color: const Color(0xFF4CAF50),
                            width: buttonWidth,
                            isSmall: isSmallScreen,
                            onTap: controller.navigateToQueue,
                          ),
                          _buildActionButton(
                            icon: Icons.medical_services_rounded,
                            label: 'Daftar\nDokter',
                            color: const Color(0xFF2196F3),
                            width: buttonWidth,
                            isSmall: isSmallScreen,
                            onTap: () => Get.toNamed(AppRoutes.doctorList),
                          ),
                          _buildActionButton(
                            icon: Icons.person_rounded,
                            label: 'Profil\nSaya',
                            color: const Color(0xFFFF9800),
                            width: buttonWidth,
                            isSmall: isSmallScreen,
                            onTap: controller.navigateToProfile,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Day Filter Tabs
              SliverToBoxAdapter(
                child: Container(
                  height: isSmallScreen ? 46 : 50,
                  margin: EdgeInsets.only(
                    bottom: isSmallScreen ? 12 : 16,
                    top: isSmallScreen ? 4 : 8,
                  ),
                  child: GetX<PatientController>(
                    builder: (controller) {
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildDayChip('Senin', controller.selectedDay == 'Senin'),
                          _buildDayChip('Selasa', controller.selectedDay == 'Selasa'),
                          _buildDayChip('Rabu', controller.selectedDay == 'Rabu'),
                          _buildDayChip('Kamis', controller.selectedDay == 'Kamis'),
                          _buildDayChip('Jumat', controller.selectedDay == 'Jumat'),
                          _buildDayChip('Sabtu', controller.selectedDay == 'Sabtu'),
                          _buildDayChip('Minggu', controller.selectedDay == 'Minggu'),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 16 : 20,
                    isSmallScreen ? 8 : 12,
                    isSmallScreen ? 16 : 20,
                    isSmallScreen ? 12 : 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
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
                              Icons.calendar_month_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Jadwal Dokter',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF212121),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      GetX<PatientController>(
                        builder: (controller) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${controller.filteredSchedules.length} Jadwal',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Schedule List
              GetX<PatientController>(
                builder: (controller) {
                  if (controller.isLoading) {
                    return SliverFillRemaining(
                      child: Center(
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
                              'Memuat jadwal...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600]!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.filteredSchedules.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
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
                                Icons.event_busy_rounded,
                                size: 64,
                                color: Colors.grey[400]!,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Tidak ada jadwal tersedia',
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
                                'Belum ada jadwal dokter untuk hari ini',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500]!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final schedule = controller.filteredSchedules[index];
                          return _buildScheduleCard(schedule);
                        },
                        childCount: controller.filteredSchedules.length,
                      ),
                    ),
                  );
                },
              ),

              // Bottom Padding
              SliverToBoxAdapter(
                child: SizedBox(height: isSmallScreen ? 16 : 24),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required double width,
    required bool isSmall,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isSmall ? 14 : 16),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 14 : 18,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmall ? 14 : 16),
          border: Border.all(
            color: color.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isSmall ? 10 : 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isSmall ? 22 : 26,
                color: color,
              ),
            ),
            SizedBox(height: isSmall ? 6 : 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmall ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800]!,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(String day, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.filterByDay(day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF616161),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleEntity schedule) {
    final isAvailable = !schedule.isFull;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAvailable 
              ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
              : const Color(0xFFE0E0E0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAvailable
                ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isAvailable) {
              Get.snackbar(
                'Booking',
                'Fitur booking akan segera tersedia',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue[50]!,
                colorText: Colors.blue[900]!,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                icon: const Icon(Icons.event_available, color: Color(0xFF2196F3)),
                duration: const Duration(seconds: 2),
              );
            } else {
              Get.snackbar(
                'Penuh',
                'Maaf, jadwal dokter sudah penuh',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[50]!,
                colorText: Colors.red[900]!,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                icon: const Icon(Icons.event_busy, color: Color(0xFFE53935)),
                duration: const Duration(seconds: 2),
              );
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Avatar with gradient
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isAvailable
                          ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                          : [const Color(0xFFBDBDBD), const Color(0xFF9E9E9E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isAvailable 
                            ? const Color(0xFF4CAF50)
                            : Colors.grey).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              schedule.doctorName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isAvailable
                                    ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                                    : [const Color(0xFFEF5350), const Color(0xFFE53935)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: (isAvailable 
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFE53935)).withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              isAvailable ? 'Tersedia' : 'Penuh',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Specialization
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          schedule.doctorSpecialization,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1976D2),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Time and Capacity
                      Row(
                        children: [
                          // Time
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Color(0xFF757575),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  schedule.getTimeRange(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Capacity
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.people_rounded,
                                  size: 14,
                                  color: Color(0xFF757575),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${schedule.currentPatients}/${schedule.maxPatients}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
