import 'package:flutter/material.dart';

class AppSnackbar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show({
    required String title,
    required String message,
    bool isError = false,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) {
      debugPrint('[AppSnackbar] $title: $message');
      return;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
        content: Text(
          '$title\n$message',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
