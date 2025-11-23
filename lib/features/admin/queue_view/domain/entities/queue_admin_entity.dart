class QueueAdminEntity {
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

  const QueueAdminEntity({
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
        return status;
    }
  }

  String get statusColor {
    switch (status) {
      case 'menunggu':
        return 'yellow';
      case 'dipanggil':
        return 'blue';
      case 'selesai':
        return 'green';
      case 'dibatalkan':
        return 'red';
      default:
        return 'grey';
    }
  }
}
