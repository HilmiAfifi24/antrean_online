import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.type,
    required super.recipientPhone,
    required super.recipientName,
    required super.message,
    super.scheduleId,
    super.doctorName,
    required super.scheduledTime,
    super.sentAt,
    super.isSent = false,
    super.errorMessage,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      type: data['type'] as String,
      recipientPhone: data['recipient_phone'] as String,
      recipientName: data['recipient_name'] as String,
      message: data['message'] as String,
      scheduleId: data['schedule_id'] as String?,
      doctorName: data['doctor_name'] as String?,
      scheduledTime: (data['scheduled_time'] as Timestamp).toDate(),
      sentAt: data['sent_at'] != null ? (data['sent_at'] as Timestamp).toDate() : null,
      isSent: data['is_sent'] as bool? ?? false,
      errorMessage: data['error_message'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'recipient_phone': recipientPhone,
      'recipient_name': recipientName,
      'message': message,
      'schedule_id': scheduleId,
      'doctor_name': doctorName,
      'scheduled_time': Timestamp.fromDate(scheduledTime),
      'sent_at': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'is_sent': isSent,
      'error_message': errorMessage,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
