import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isSmallScreen;

  const CustomButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isSmallScreen ? 10 : 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: isSmallScreen ? 48 : 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutlined ? Colors.white : const Color(0xFF3B82F6),
            foregroundColor: isOutlined ? const Color(0xFF3B82F6) : Colors.white,
            elevation: isOutlined ? 0 : 2,
            shadowColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isOutlined
                  ? const BorderSide(color: Color(0xFF3B82F6), width: 1.5)
                  : BorderSide.none,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 24,
              vertical: isSmallScreen ? 12 : 14,
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: isSmallScreen ? 20 : 24,
                  width: isSmallScreen ? 20 : 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: isSmallScreen ? 18 : 20,
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 10),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}