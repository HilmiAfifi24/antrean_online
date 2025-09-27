import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antrean_online/core/routes/app_routes.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_hospital,
                        size: 50,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'KLINIK PENS',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sistem Antrean Online',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Role Selection
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Pilih Role Anda',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 32),
                      
                      // Admin Role
                      _buildRoleCard(
                        title: 'Administrator',
                        subtitle: 'Kelola sistem dan data klinik',
                        icon: Icons.admin_panel_settings,
                        color: Color(0xFFEF4444),
                        onTap: () => Get.toNamed(AppRoutes.adminSplash),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Doctor Role
                      _buildRoleCard(
                        title: 'Dokter',
                        subtitle: 'Kelola jadwal dan pasien',
                        icon: Icons.medical_services,
                        color: Color(0xFF10B981),
                        onTap: () => Get.toNamed(AppRoutes.doctorSplash),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Patient Role
                      _buildRoleCard(
                        title: 'Pasien',
                        subtitle: 'Daftar antrean dan konsultasi',
                        icon: Icons.person,
                        color: Color(0xFF8B5CF6),
                        onTap: () => Get.toNamed(AppRoutes.patientSplash),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '© 2024 PENS - Politeknik Elektronika Negeri Surabaya',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}