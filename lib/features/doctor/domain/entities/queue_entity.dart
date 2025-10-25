class QueueEntity {
  final String id;
  final String patientName;
  final int queueNumber;
  final String status;
  final String complaint;

  QueueEntity({
    required this.id,
    required this.patientName,
    required this.queueNumber,
    required this.status,
    required this.complaint,
  });
}
