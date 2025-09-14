import 'package:antrean_online/features/admin/schedule_view/domain/entities/schedule_admin_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleAdminModel extends ScheduleAdminEntity {
  const ScheduleAdminModel({
    required super.id,
    required super.doctorId,
    required super.doctorName,
    required super.doctorSpecialization,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.daysOfWeek,
    required super.maxPatients,
    required super.currentPatients,
    required super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory ScheduleAdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    TimeOfDay parseTimeOfDay(String time) {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }

    return ScheduleAdminModel(
      id: doc.id,
      doctorId: data['doctor_id'] ?? '',
      doctorName: data['doctor_name'] ?? '',
      doctorSpecialization: data['doctor_specialization'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: parseTimeOfDay(data['start_time'] ?? '00:00'),
      endTime: parseTimeOfDay(data['end_time'] ?? '00:00'),
      daysOfWeek: List<String>.from(data['days_of_week'] ?? []),
      maxPatients: data['max_patients'] ?? 0,
      currentPatients: data['current_patients'] ?? 0,
      isActive: data['is_active'] ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    String formatTimeOfDay(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return {
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_specialization': doctorSpecialization,
      'date': Timestamp.fromDate(date),
      'start_time': formatTimeOfDay(startTime),
      'end_time': formatTimeOfDay(endTime),
      'days_of_week': daysOfWeek,
      'max_patients': maxPatients,
      'current_patients': currentPatients,
      'is_active': isActive,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreForUpdate() {
    String formatTimeOfDay(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return {
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_specialization': doctorSpecialization,
      'date': Timestamp.fromDate(date),
      'start_time': formatTimeOfDay(startTime),
      'end_time': formatTimeOfDay(endTime),
      'days_of_week': daysOfWeek,
      'max_patients': maxPatients,
      'current_patients': currentPatients,
      'is_active': isActive,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory ScheduleAdminModel.fromEntity(ScheduleAdminEntity schedule) {
    return ScheduleAdminModel(
      id: schedule.id,
      doctorId: schedule.doctorId,
      doctorName: schedule.doctorName,
      doctorSpecialization: schedule.doctorSpecialization,
      date: schedule.date,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      daysOfWeek: schedule.daysOfWeek,
      maxPatients: schedule.maxPatients,
      currentPatients: schedule.currentPatients,
      isActive: schedule.isActive,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
  }

  @override
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
    return ScheduleAdminModel(
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

  // Convert model to entity
  ScheduleAdminEntity toEntity() {
    return ScheduleAdminEntity(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      date: date,
      startTime: startTime,
      endTime: endTime,
      daysOfWeek: daysOfWeek,
      maxPatients: maxPatients,
      currentPatients: currentPatients,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
