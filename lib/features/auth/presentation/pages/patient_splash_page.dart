import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antrean_online/core/routes/app_routes.dart';

class PatientSplashPage extends StatefulWidget {
  const PatientSplashPage({super.key});
  @override
  State<PatientSplashPage> createState() => _PatientSplashPageState();
}

class _PatientSplashPageState extends State<PatientSplashPage>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _fadeController;
  late Animation<double> _heartAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _heartController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _startAnimation();
  }

  void _startAnimation() async {
    _fadeController.forward();
    _heartController.repeat(reverse: true);
    
    // Auto navigate after 4 seconds
    await Future.delayed(Duration(seconds: 4));
    Get.offNamed(AppRoutes.login, parameters: {'role': 'patient'});
  }

  @override
  void dispose() {
    _heartController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isVerySmallScreen = size.height < 600;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7C3AED),
              Color(0xFF8B5CF6),
              Color(0xFFA78BFA),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isVerySmallScreen ? 20 : (isSmallScreen ? 30 : 40),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _heartAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _heartAnimation.value,
                            child: Container(
                              width: isVerySmallScreen ? 80 : (isSmallScreen ? 100 : 120),
                              height: isVerySmallScreen ? 80 : (isSmallScreen ? 100 : 120),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 30,
                                    offset: Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.favorite,
                                size: isVerySmallScreen ? 40 : (isSmallScreen ? 50 : 60),
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 32),
                      Text(
                        'PASIEN',
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 24 : (isSmallScreen ? 28 : 32),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 16),
                      Text(
                        'Layanan Kesehatan Digital',
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Service cards
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 32,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildServiceCard(
                              icon: Icons.calendar_today,
                              title: 'Daftar Antrean',
                              subtitle: 'Booking mudah',
                              color: Colors.blue,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 16),
                            Expanded(
                              child: _buildServiceCard(
                                icon: Icons.access_time,
                                title: 'Cek Jadwal',
                                subtitle: 'Real-time',
                                color: Colors.green,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildServiceCard(
                                icon: Icons.notifications,
                                title: 'Notifikasi',
                                subtitle: 'Update antrean',
                                color: Colors.orange,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 16),
                            Expanded(
                              child: _buildServiceCard(
                                icon: Icons.history,
                                title: 'Riwayat',
                                subtitle: 'Kunjungan',
                                color: Colors.red,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 32),
                        
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Selamat Datang!',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              Text(
                                'Daftar antrean online, pantau jadwal dokter, dan nikmati layanan kesehatan yang lebih mudah',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Get.offNamed(AppRoutes.login, parameters: {'role': 'patient'}),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 10 : 12,
                                  ),
                                ),
                                child: Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Get.offNamed(AppRoutes.register),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF7C3AED),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 10 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
  
  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool isSmallScreen = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 32 : 40,
            height: isSmallScreen ? 32 : 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isSmallScreen ? 16 : 20,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}