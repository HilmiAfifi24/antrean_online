import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/schedule_entity.dart';

class ScheduleRemoteDataSource {
  final FirebaseFirestore firestore;

  ScheduleRemoteDataSource(this.firestore);

  // Get all active schedules with doctor details
  Future<List<ScheduleEntity>> getAllActiveSchedules() async {
    try {
      final snapshot = await firestore
          .collection('schedules')
          .where('is_active', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ScheduleEntity(
          id: doc.id,
          doctorId: data['doctor_id'] ?? '',
          doctorName: data['doctor_name'] ?? '',
          doctorSpecialization: data['doctor_specialization'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          startTime: _parseTimeOfDay(data['start_time']),
          endTime: _parseTimeOfDay(data['end_time']),
          daysOfWeek: List<String>.from(data['days_of_week'] ?? []),
          maxPatients: data['max_patients'] ?? 0,
          currentPatients: data['current_patients'] ?? 0,
          isActive: data['is_active'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load schedules: $e');
    }
  }

  // Get schedules by day
  Future<List<ScheduleEntity>> getSchedulesByDay(String day) async {
    try {
      final snapshot = await firestore
          .collection('schedules')
          .where('is_active', isEqualTo: true)
          .where('days_of_week', arrayContains: day)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ScheduleEntity(
          id: doc.id,
          doctorId: data['doctor_id'] ?? '',
          doctorName: data['doctor_name'] ?? '',
          doctorSpecialization: data['doctor_specialization'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          startTime: _parseTimeOfDay(data['start_time']),
          endTime: _parseTimeOfDay(data['end_time']),
          daysOfWeek: List<String>.from(data['days_of_week'] ?? []),
          maxPatients: data['max_patients'] ?? 0,
          currentPatients: data['current_patients'] ?? 0,
          isActive: data['is_active'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load schedules by day: $e');
    }
  }

  // Search schedules by doctor name
  Future<List<ScheduleEntity>> searchSchedules(String query) async {
    try {
      final snapshot = await firestore
          .collection('schedules')
          .where('is_active', isEqualTo: true)
          .get();

      final schedules = snapshot.docs.map((doc) {
        final data = doc.data();
        return ScheduleEntity(
          id: doc.id,
          doctorId: data['doctor_id'] ?? '',
          doctorName: data['doctor_name'] ?? '',
          doctorSpecialization: data['doctor_specialization'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          startTime: _parseTimeOfDay(data['start_time']),
          endTime: _parseTimeOfDay(data['end_time']),
          daysOfWeek: List<String>.from(data['days_of_week'] ?? []),
          maxPatients: data['max_patients'] ?? 0,
          currentPatients: data['current_patients'] ?? 0,
          isActive: data['is_active'] ?? false,
        );
      }).toList();

      // Filter by doctor name
      return schedules.where((schedule) =>
        schedule.doctorName.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search schedules: $e');
    }
  }

  TimeOfDay _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
