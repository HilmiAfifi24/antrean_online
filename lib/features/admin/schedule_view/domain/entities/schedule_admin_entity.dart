import 'package:flutter/material.dart';

class ScheduleAdminEntity {
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
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ScheduleAdminEntity({
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
    required this.createdAt,
    this.updatedAt,
  });

  ScheduleAdminEntity copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialization,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<String>? daysOfWeek,
    int? maxPatients,
    int? currentPatients,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleAdminEntity(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialization: doctorSpecialization ?? this.doctorSpecialization,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      maxPatients: maxPatients ?? this.maxPatients,
      currentPatients: currentPatients ?? this.currentPatients,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
