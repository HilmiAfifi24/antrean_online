import 'dart:async';
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

      // Convert schedule documents to entities with dynamic patient count
      final schedulesList = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          
          // Get the actual appointment date for this schedule
          final scheduleDate = data['date'] != null
              ? (data['date'] as Timestamp).toDate()
              : DateTime.now();
          final daysOfWeek = List<String>.from(data['days_of_week'] ?? []);
          
          // Calculate the next occurrence of this schedule based on current day
          final now = DateTime.now();
          DateTime appointmentDate = scheduleDate;
          
          // Find the nearest upcoming date that matches one of the daysOfWeek
          final dayNameMap = {
            'Senin': DateTime.monday,
            'Selasa': DateTime.tuesday,
            'Rabu': DateTime.wednesday,
            'Kamis': DateTime.thursday,
            'Jumat': DateTime.friday,
            'Sabtu': DateTime.saturday,
            'Minggu': DateTime.sunday,
          };
          
          // Find the closest upcoming date
          DateTime? closestDate;
          for (final dayName in daysOfWeek) {
            final targetWeekday = dayNameMap[dayName];
            if (targetWeekday != null) {
              int daysUntil = (targetWeekday - now.weekday + 7) % 7;
              final candidate = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntil));
              if (closestDate == null || candidate.isBefore(closestDate)) {
                closestDate = candidate;
              }
            }
          }
          
          if (closestDate != null) {
            appointmentDate = closestDate;
          }
          
          // Normalize date to midnight for comparison
          final normalizedDate = DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
          );
          
          // Count active queues for this schedule on the appointment date
          final queueSnapshot = await firestore
              .collection('queues')
              .where('schedule_id', isEqualTo: doc.id)
              .where('appointment_date', isEqualTo: Timestamp.fromDate(normalizedDate))
              .where('status', whereIn: ['menunggu', 'dipanggil', 'selesai'])
              .get();
          
          final currentPatients = queueSnapshot.docs.length;
          
          return ScheduleEntity(
            id: doc.id,
            doctorId: data['doctor_id'] ?? '',
            doctorName: data['doctor_name'] ?? '',
            doctorSpecialization: data['doctor_specialization'] ?? '',
            date: appointmentDate,
            startTime: _parseTimeOfDay(data['start_time']),
            endTime: _parseTimeOfDay(data['end_time']),
            daysOfWeek: daysOfWeek,
            maxPatients: data['max_patients'] ?? 0,
            currentPatients: currentPatients, // Dynamic count based on actual queues
            isActive: data['is_active'] ?? false,
          );
        }).toList(),
      );

      return schedulesList;
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

      // Convert schedule documents to entities with dynamic patient count
      final schedulesList = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          
          // Calculate the appointment date for the selected day
          final now = DateTime.now();
          final dayNameMap = {
            'Senin': DateTime.monday,
            'Selasa': DateTime.tuesday,
            'Rabu': DateTime.wednesday,
            'Kamis': DateTime.thursday,
            'Jumat': DateTime.friday,
            'Sabtu': DateTime.saturday,
            'Minggu': DateTime.sunday,
          };
          
          final targetWeekday = dayNameMap[day];
          int daysUntil = 0;
          if (targetWeekday != null) {
            daysUntil = (targetWeekday - now.weekday + 7) % 7;
            // If today matches the target day, use today (0 days)
            // Otherwise use the calculated future date
          }
          
          final appointmentDate = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntil));
          
          // Normalize date to midnight for comparison
          final normalizedDate = DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
          );
          
          // Count active queues for this schedule on the appointment date
          final queueSnapshot = await firestore
              .collection('queues')
              .where('schedule_id', isEqualTo: doc.id)
              .where('appointment_date', isEqualTo: Timestamp.fromDate(normalizedDate))
              .where('status', whereIn: ['menunggu', 'dipanggil', 'selesai'])
              .get();
          
          final currentPatients = queueSnapshot.docs.length;
          
          return ScheduleEntity(
            id: doc.id,
            doctorId: data['doctor_id'] ?? '',
            doctorName: data['doctor_name'] ?? '',
            doctorSpecialization: data['doctor_specialization'] ?? '',
            date: appointmentDate,
            startTime: _parseTimeOfDay(data['start_time']),
            endTime: _parseTimeOfDay(data['end_time']),
            daysOfWeek: List<String>.from(data['days_of_week'] ?? []),
            maxPatients: data['max_patients'] ?? 0,
            currentPatients: currentPatients, // Dynamic count based on actual queues
            isActive: data['is_active'] ?? false,
          );
        }).toList(),
      );

      return schedulesList;
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

      final schedulesList = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          
          // Get the actual appointment date for this schedule
          final scheduleDate = data['date'] != null
              ? (data['date'] as Timestamp).toDate()
              : DateTime.now();
          final daysOfWeek = List<String>.from(data['days_of_week'] ?? []);
          
          // Calculate the next occurrence of this schedule based on current day
          final now = DateTime.now();
          DateTime appointmentDate = scheduleDate;
          
          // Find the nearest upcoming date that matches one of the daysOfWeek
          final dayNameMap = {
            'Senin': DateTime.monday,
            'Selasa': DateTime.tuesday,
            'Rabu': DateTime.wednesday,
            'Kamis': DateTime.thursday,
            'Jumat': DateTime.friday,
            'Sabtu': DateTime.saturday,
            'Minggu': DateTime.sunday,
          };
          
          // Find the closest upcoming date
          DateTime? closestDate;
          for (final dayName in daysOfWeek) {
            final targetWeekday = dayNameMap[dayName];
            if (targetWeekday != null) {
              int daysUntil = (targetWeekday - now.weekday + 7) % 7;
              final candidate = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntil));
              if (closestDate == null || candidate.isBefore(closestDate)) {
                closestDate = candidate;
              }
            }
          }
          
          if (closestDate != null) {
            appointmentDate = closestDate;
          }
          
          // Normalize date to midnight for comparison
          final normalizedDate = DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
          );
          
          // Count active queues for this schedule on the appointment date
          final queueSnapshot = await firestore
              .collection('queues')
              .where('schedule_id', isEqualTo: doc.id)
              .where('appointment_date', isEqualTo: Timestamp.fromDate(normalizedDate))
              .where('status', whereIn: ['menunggu', 'dipanggil', 'selesai'])
              .get();
          
          final currentPatients = queueSnapshot.docs.length;
          
          return ScheduleEntity(
            id: doc.id,
            doctorId: data['doctor_id'] ?? '',
            doctorName: data['doctor_name'] ?? '',
            doctorSpecialization: data['doctor_specialization'] ?? '',
            date: appointmentDate,
            startTime: _parseTimeOfDay(data['start_time']),
            endTime: _parseTimeOfDay(data['end_time']),
            daysOfWeek: daysOfWeek,
            maxPatients: data['max_patients'] ?? 0,
            currentPatients: currentPatients, // Dynamic count based on actual queues
            isActive: data['is_active'] ?? false,
          );
        }).toList(),
      );

      // Filter by doctor name
      return schedulesList.where((schedule) =>
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

  // Real-time stream for schedules by day with queue count updates
  Stream<List<ScheduleEntity>> getSchedulesByDayStream(String day) {
    try {
      // Create a stream controller to combine both schedules and queues streams
      late StreamController<List<ScheduleEntity>> controller;
      StreamSubscription? schedulesSubscription;
      StreamSubscription? queuesSubscription;
      
      controller = StreamController<List<ScheduleEntity>>(
        onListen: () {
          // Function to rebuild schedule list with current patient counts
          Future<void> updateSchedules() async {
            try {
              final snapshot = await firestore
                  .collection('schedules')
                  .where('is_active', isEqualTo: true)
                  .where('days_of_week', arrayContains: day)
                  .get();

              final schedulesList = await Future.wait(
                snapshot.docs.map((doc) async {
                  final data = doc.data();
                  
                  // Calculate the appointment date for the selected day
                  final now = DateTime.now();
                  final dayNameMap = {
                    'Senin': DateTime.monday,
                    'Selasa': DateTime.tuesday,
                    'Rabu': DateTime.wednesday,
                    'Kamis': DateTime.thursday,
                    'Jumat': DateTime.friday,
                    'Sabtu': DateTime.saturday,
                    'Minggu': DateTime.sunday,
                  };
                  
                  final targetWeekday = dayNameMap[day];
                  int daysUntil = 0;
                  if (targetWeekday != null) {
                    daysUntil = (targetWeekday - now.weekday + 7) % 7;
                  }
                  
                  final appointmentDate = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntil));
                  
                  // Normalize date to midnight for comparison
                  final normalizedDate = DateTime(
                    appointmentDate.year,
                    appointmentDate.month,
                    appointmentDate.day,
                  );
                  
                  // Count active queues for this schedule on the appointment date
                  final queueSnapshot = await firestore
                      .collection('queues')
                      .where('schedule_id', isEqualTo: doc.id)
                      .where('appointment_date', isEqualTo: Timestamp.fromDate(normalizedDate))
                      .where('status', whereIn: ['menunggu', 'dipanggil', 'selesai'])
                      .get();
                  
                  final currentPatients = queueSnapshot.docs.length;
                  
                  return ScheduleEntity(
                    id: doc.id,
                    doctorId: data['doctor_id'] ?? '',
                    doctorName: data['doctor_name'] ?? '',
                    doctorSpecialization: data['doctor_specialization'] ?? '',
                    date: appointmentDate,
                    startTime: _parseTimeOfDay(data['start_time']),
                    endTime: _parseTimeOfDay(data['end_time']),
                    daysOfWeek: List<String>.from(data['days_of_week'] ?? []),
                    maxPatients: data['max_patients'] ?? 0,
                    currentPatients: currentPatients, // Real-time count from queues
                    isActive: data['is_active'] ?? false,
                  );
                }).toList(),
              );

              if (!controller.isClosed) {
                controller.add(schedulesList);
              }
            } catch (e) {
              if (!controller.isClosed) {
                controller.addError(e);
              }
            }
          }

          // Listen to schedules collection changes
          schedulesSubscription = firestore
              .collection('schedules')
              .where('is_active', isEqualTo: true)
              .where('days_of_week', arrayContains: day)
              .snapshots()
              .listen((_) {
            updateSchedules();
          });

          // Listen to queues collection changes
          queuesSubscription = firestore
              .collection('queues')
              .snapshots()
              .listen((_) {
            updateSchedules();
          });

          // Initial load
          updateSchedules();
        },
        onCancel: () {
          schedulesSubscription?.cancel();
          queuesSubscription?.cancel();
        },
      );

      return controller.stream;
    } catch (e) {
      throw Exception('Failed to stream schedules by day: $e');
    }
  }
}
