class QueueEntity {
  final String id;
  final String patientId;
  final String patientName;
  final String scheduleId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime appointmentDate;
  final String appointmentTime;
  final int queueNumber;
  final String status; // 'menunggu', 'dipanggil', 'selesai', 'dibatalkan'
  final String complaint;
  final DateTime createdAt;
  final Map<String, dynamic>? rescheduledFrom;
  final DateTime? rescheduledAt;
  final String? cancellationReason;

  QueueEntity({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.scheduleId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.queueNumber,
    required this.status,
    required this.complaint,
    required this.createdAt,
    this.rescheduledFrom,
    this.rescheduledAt,
    this.cancellationReason,
  });

  // Helper getters
  String get statusText {
    switch (status) {
      case 'menunggu':
      case 'waiting':
        return 'Menunggu';
      case 'dipanggil':
      case 'ongoing':
        return 'Dipanggil';
      case 'selesai':
      case 'completed':
        return 'Selesai';
      case 'dibatalkan':
      case 'cancelled_by_patient':
        return 'Dibatalkan';
      case 'cancelled_by_doctor':
        return 'Dibatalkan Dokter';
      case 'rescheduled':
        return 'Dijadwalkan Ulang';
      default:
        return 'Unknown';
    }
  }

  String get formattedDate {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${appointmentDate.day} ${months[appointmentDate.month - 1]} ${appointmentDate.year}';
  }

  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
    );
    return appointmentDay.isBefore(today);
  }

  bool get isActive {
    return (status == 'menunggu' ||
            status == 'waiting' ||
            status == 'dipanggil' ||
            status == 'ongoing' ||
            status == 'rescheduled') &&
        !isExpired;
  }

  bool get canRequestReschedule {
    return status == 'menunggu' ||
        status == 'waiting' ||
        status == 'cancelled_by_doctor';
  }
}
