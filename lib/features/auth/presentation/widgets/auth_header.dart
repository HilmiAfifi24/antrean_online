import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSmallScreen;
  final bool isVerySmallScreen;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isSmallScreen = false,
    this.isVerySmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: isVerySmallScreen ? 70 : (isSmallScreen ? 80 : 100),
          height: isVerySmallScreen ? 70 : (isSmallScreen ? 80 : 100),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: isVerySmallScreen ? 35 : (isSmallScreen ? 40 : 50),
            color: Colors.white,
          ),
        ),
        SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
        Text(
          title,
          style: TextStyle(
            fontSize: isVerySmallScreen ? 22 : (isSmallScreen ? 26 : 32),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14),
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: isVerySmallScreen ? 24 : (isSmallScreen ? 28 : 32)),
      ],
    );
  }
}