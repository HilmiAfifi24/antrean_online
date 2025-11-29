class NotificationEntity {
  final String id;
  final String type; // 'queue_opened', 'practice_started'
  final String recipientPhone;
  final String recipientName;
  final String message;
  final String? scheduleId;
  final String? doctorName;
  final DateTime scheduledTime;
  final DateTime? sentAt;
  final bool isSent;
  final String? errorMessage;

  NotificationEntity({
    required this.id,
    required this.type,
    required this.recipientPhone,
    required this.recipientName,
    required this.message,
    this.scheduleId,
    this.doctorName,
    required this.scheduledTime,
    this.sentAt,
    this.isSent = false,
    this.errorMessage,
  });

  NotificationEntity copyWith({
    String? id,
    String? type,
    String? recipientPhone,
    String? recipientName,
    String? message,
    String? scheduleId,
    String? doctorName,
    DateTime? scheduledTime,
    DateTime? sentAt,
    bool? isSent,
    String? errorMessage,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      message: message ?? this.message,
      scheduleId: scheduleId ?? this.scheduleId,
      doctorName: doctorName ?? this.doctorName,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      sentAt: sentAt ?? this.sentAt,
      isSent: isSent ?? this.isSent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
