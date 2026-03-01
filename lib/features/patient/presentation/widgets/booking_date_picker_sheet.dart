import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/schedule_date_availability.dart';
import '../controllers/patient_controller.dart';
import '../controllers/queue_controller.dart';
import '../bindings/queue_binding.dart' as import_queue_binding;

class BookingDatePickerSheet extends StatefulWidget {
  final ScheduleEntity schedule;

  const BookingDatePickerSheet({super.key, required this.schedule});

  @override
  State<BookingDatePickerSheet> createState() => _BookingDatePickerSheetState();
}

class _BookingDatePickerSheetState extends State<BookingDatePickerSheet> {
  final PatientController patientController = Get.find<PatientController>();

  // To store the calculated upcoming dates
  late List<DateTime> _upcomingDates;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _calculateUpcomingDates();
  }

  void _calculateUpcomingDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _upcomingDates = [];

    // Map Indonesian day names to weekday ints
    final map = {
      'Senin': DateTime.monday,
      'Selasa': DateTime.tuesday,
      'Rabu': DateTime.wednesday,
      'Kamis': DateTime.thursday,
      'Jumat': DateTime.friday,
      'Sabtu': DateTime.saturday,
      'Minggu': DateTime.sunday,
    };

    // We only create dates for the specific day of week currently selected
    final selectedDay = patientController.selectedDay;
    final targetWeekday = map[selectedDay];

    if (targetWeekday != null) {
      int daysUntil = (targetWeekday - today.weekday + 7) % 7;
      DateTime firstOccurrence = today.add(Duration(days: daysUntil));

      // Get the next 4 occurrences of this day
      for (int i = 0; i < 4; i++) {
        _upcomingDates.add(firstOccurrence.add(Duration(days: 7 * i)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_upcomingDates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Text('Hari tidak valid.'),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Tanggal Booking',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dokter: ${widget.schedule.doctorName}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  'Spesialis: ${widget.schedule.doctorSpecialization}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),

          // Stream list of dates
          StreamBuilder<List<ScheduleDateAvailability>>(
            stream: patientController.getScheduleDatesStream(
              widget.schedule.id,
              _upcomingDates,
              widget.schedule.maxPatients,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Gagal memuat jadwal',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                );
              }

              final availabilities = snapshot.data ?? [];

              if (availabilities.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Tidak ada tanggal tersedia.')),
                );
              }

              return Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  itemCount: availabilities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = availabilities[index];
                    final isAvailable = !item.isFull;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Safe check: Re-initialize dependencies if GetX accidentally deleted them on route pop
                          if (!Get.isRegistered<QueueController>()) {
                            import_queue_binding.QueueBinding().dependencies();
                          }

                          // Check if user already has an active queue BEFORE checking availability
                          var queueController = Get.find<QueueController>();
                          if (queueController.hasActiveQueue) {
                            Get.snackbar(
                              'Gagal',
                              'Anda sudah memiliki antrean aktif. Silakan selesaikan atau batalkan antrean sebelumnya.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.orange[50]!,
                              colorText: Colors.orange[900]!,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              icon: const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFF57C00),
                              ),
                            );
                            return; // Stop execution
                          }

                          if (isAvailable) {
                            Get.back(); // close bottom sheet

                            // Navigate and pass specific date
                            final specificSchedule = ScheduleEntity(
                              id: widget.schedule.id,
                              doctorId: widget.schedule.doctorId,
                              doctorName: widget.schedule.doctorName,
                              doctorSpecialization:
                                  widget.schedule.doctorSpecialization,
                              date: item.date,
                              startTime: widget.schedule.startTime,
                              endTime: widget.schedule.endTime,
                              daysOfWeek: widget.schedule.daysOfWeek,
                              maxPatients: widget.schedule.maxPatients,
                              currentPatients: item.currentPatients,
                              isActive: widget.schedule.isActive,
                            );

                            Get.toNamed(
                              '/patient/booking',
                              arguments: specificSchedule,
                            );
                          } else {
                            Get.snackbar(
                              'Penuh',
                              'Maaf, kuota untuk tanggal ini sudah penuh.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red[50]!,
                              colorText: Colors.red[900]!,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              icon: const Icon(
                                Icons.event_busy,
                                color: Color(0xFFE53935),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isAvailable
                                  ? const Color(
                                      0xFF4CAF50,
                                    ).withValues(alpha: 0.3)
                                  : const Color(0xFFE0E0E0),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: isAvailable
                                ? const Color(0xFFF1F8E9)
                                : const Color(0xFFF5F5F5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Date column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'EEEE, d MMMM y',
                                      'id_ID',
                                    ).format(item.date),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isAvailable
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFF9E9E9E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.schedule.getTimeRange(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isAvailable
                                          ? const Color(0xFF388E3C)
                                          : const Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ],
                              ),
                              // Slot Info
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isAvailable
                                        ? const Color(0xFF81C784)
                                        : const Color(0xFFE0E0E0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${item.currentPatients} / ${item.maxPatients}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFF9E9E9E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
