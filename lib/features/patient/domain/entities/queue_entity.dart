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
  });

  // Helper getters
  String get statusText {
    switch (status) {
      case 'menunggu':
        return 'Menunggu';
      case 'dipanggil':
        return 'Dipanggil';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  String get formattedDate {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${appointmentDate.day} ${months[appointmentDate.month - 1]} ${appointmentDate.year}';
  }

  bool get isActive {
    return status == 'menunggu' || status == 'dipanggil';
  }
}
