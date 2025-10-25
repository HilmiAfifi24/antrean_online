import 'package:flutter/material.dart';

class ScheduleEntity {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<String> daysOfWeek;
  final int maxPatients;
  final int currentPatients;
  final bool isActive;

  ScheduleEntity({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.maxPatients,
    required this.currentPatients,
    required this.isActive,
  });

  bool get isFull => currentPatients >= maxPatients;

  String get doctorInitials {
    if (doctorName.isEmpty) return 'DR';
    
    final parts = doctorName.split(' ');
    if (parts.length == 1) {
      // Single word name
      return parts[0].length >= 2 
          ? parts[0].substring(0, 2).toUpperCase()
          : parts[0].toUpperCase();
    } else {
      // Multiple words - get first letter of first two words
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }

  String getTimeRange() {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
}
