import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../../../core/routes/app_routes.dart';

class SelectSchedulePage extends StatefulWidget {
  const SelectSchedulePage({super.key});

  @override
  State<SelectSchedulePage> createState() => _SelectSchedulePageState();
}

class _SelectSchedulePageState extends State<SelectSchedulePage> {
  String selectedDay = '';
  final List<String> availableDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    selectedDay = _getTodayDayName();
  }

  String _getTodayDayName() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return 'Senin';
    }
  }

  String _getDayNameFromDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }

  // Mengembalikan nearest DateTime yang jatuh pada hari yang diberikan (nama hari bahasa Indonesia)
  DateTime _getNearestDateForDay(String dayName) {
    final now = DateTime.now();
    int targetWeekday;
    switch (dayName) {
      case 'Senin':
        targetWeekday = DateTime.monday;
        break;
      case 'Selasa':
        targetWeekday = DateTime.tuesday;
        break;
      case 'Rabu':
        targetWeekday = DateTime.wednesday;
        break;
      case 'Kamis':
        targetWeekday = DateTime.thursday;
        break;
      case 'Jumat':
        targetWeekday = DateTime.friday;
        break;
      case 'Sabtu':
        targetWeekday = DateTime.saturday;
        break;
      case 'Minggu':
        targetWeekday = DateTime.sunday;
        break;
      default:
        targetWeekday = now.weekday;
    }

    int daysUntil = (targetWeekday - now.weekday) % 7;
    if (daysUntil < 0) daysUntil += 7;
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysUntil));
  }

  TimeOfDay _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    final parts = timeString.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Widget _buildDayFilter() {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableDays.length,
        itemBuilder: (context, index) {
          final day = availableDays[index];
          final isSelected = selectedDay == day;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = day;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Jadwal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada jadwal dokter\npada hari ini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleEntity schedule) {
    // Determine the appointment date based on the selected day.
    DateTime correctDate;
    if (schedule.daysOfWeek.contains(selectedDay)) {
      correctDate = _getNearestDateForDay(selectedDay);
    } else if (schedule.daysOfWeek.contains(_getDayNameFromDate(schedule.date))) {
      correctDate = schedule.date;
    } else {
      correctDate = _getNearestDateForDay(selectedDay);
    }

    // Count booked slots for this schedule on the specific appointment date.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queues')
          .where('schedule_id', isEqualTo: schedule.id)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(DateTime(correctDate.year, correctDate.month, correctDate.day)))
          .where('status', whereIn: ['menunggu', 'dipanggil', 'selesai'])
          .snapshots(),
      builder: (context, snap) {
        final booked = (snap.hasData) ? snap.data!.docs.length : 0;
        final availableSlots = schedule.maxPatients - booked;
        final isFull = availableSlots <= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isFull
                  ? null
                  : () {
                      final fixedSchedule = ScheduleEntity(
                        id: schedule.id,
                        doctorId: schedule.doctorId,
                        doctorName: schedule.doctorName,
                        doctorSpecialization: schedule.doctorSpecialization,
                        date: correctDate,
                        startTime: schedule.startTime,
                        endTime: schedule.endTime,
                        daysOfWeek: schedule.daysOfWeek,
                        maxPatients: schedule.maxPatients,
                        currentPatients: booked,
                        isActive: schedule.isActive,
                      );
                      Get.toNamed(AppRoutes.booking, arguments: fixedSchedule);
                    },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          schedule.doctorInitials,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.doctorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            schedule.doctorSpecialization,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                schedule.getTimeRange(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isFull ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isFull ? 'Penuh' : 'Tersedia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isFull ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$availableSlots slot',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
            child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Pilih Jadwal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pilih hari dan jadwal dokter yang tersedia',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom AppBar
          _buildAppBar(context),
          // Content area with rounded top corners
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Day Filter
                  _buildDayFilter(),
                  // Schedule List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('schedules')
                          .where('is_active', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState();
                        }

                        // Parse schedules safely
                        final schedules = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          DateTime date = DateTime.now();
                          if (data['date'] != null && data['date'] is Timestamp) {
                            date = (data['date'] as Timestamp).toDate();
                          }
                          return ScheduleEntity(
                            id: doc.id,
                            doctorId: data['doctor_id'] ?? '',
                            doctorName: data['doctor_name'] ?? '',
                            doctorSpecialization: data['doctor_specialization'] ?? '',
                            date: date,
                            startTime: _parseTimeOfDay(data['start_time'] as String?),
                            endTime: _parseTimeOfDay(data['end_time'] as String?),
                            daysOfWeek: List<String>.from(data['days_of_week'] ?? []),
                            maxPatients: (data['max_patients'] ?? 0) as int,
                            currentPatients: (data['current_patients'] ?? 0) as int,
                            isActive: data['is_active'] ?? false,
                          );
                        }).toList();

                        // Filter by selected day
                        final filteredSchedules = schedules
                            .where((schedule) => schedule.daysOfWeek.contains(selectedDay))
                            .toList();

                        if (filteredSchedules.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredSchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = filteredSchedules[index];
                            return _buildScheduleCard(schedule);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
