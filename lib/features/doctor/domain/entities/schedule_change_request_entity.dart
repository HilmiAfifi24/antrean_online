import 'package:cloud_firestore/cloud_firestore.dart';

enum ScheduleChangeRequestStatus { pending, approved, rejected }

extension ScheduleChangeRequestStatusX on ScheduleChangeRequestStatus {
  String get value {
    switch (this) {
      case ScheduleChangeRequestStatus.pending:
        return 'pending';
      case ScheduleChangeRequestStatus.approved:
        return 'approved';
      case ScheduleChangeRequestStatus.rejected:
        return 'rejected';
    }
  }

  static ScheduleChangeRequestStatus fromString(String value) {
    switch (value) {
      case 'approved':
        return ScheduleChangeRequestStatus.approved;
      case 'rejected':
        return ScheduleChangeRequestStatus.rejected;
      default:
        return ScheduleChangeRequestStatus.pending;
    }
  }
}

class ScheduleChangeRequestEntity {
  final String requestId;
  final String doctorId;
  final String doctorName;
  final String doctorPhone;
  final String oldScheduleId;
  final String oldDay;
  final String oldStartTime;
  final String oldEndTime;
  final String newDay;
  final String newStartTime;
  final String newEndTime;
  final String reason;
  final ScheduleChangeRequestStatus status;
  final String? adminApproverId;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? approvedAt;

  const ScheduleChangeRequestEntity({
    required this.requestId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhone,
    required this.oldScheduleId,
    required this.oldDay,
    required this.oldStartTime,
    required this.oldEndTime,
    required this.newDay,
    required this.newStartTime,
    required this.newEndTime,
    required this.reason,
    required this.status,
    this.adminApproverId,
    this.rejectionReason,
    required this.createdAt,
    this.approvedAt,
  });

  factory ScheduleChangeRequestEntity.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return ScheduleChangeRequestEntity(
      requestId: doc.id,
      doctorId: data['doctor_id'] ?? '',
      doctorName: data['doctor_name'] ?? '',
      doctorPhone: data['doctor_phone'] ?? '',
      oldScheduleId: data['old_schedule_id'] ?? '',
      oldDay: data['old_day'] ?? '',
      oldStartTime: data['old_start_time'] ?? '',
      oldEndTime: data['old_end_time'] ?? '',
      newDay: data['new_day'] ?? '',
      newStartTime: data['new_start_time'] ?? '',
      newEndTime: data['new_end_time'] ?? '',
      reason: data['reason'] ?? '',
      status: ScheduleChangeRequestStatusX.fromString(data['status'] ?? ''),
      adminApproverId: data['admin_approver_id'],
      rejectionReason: data['rejection_reason'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (data['approved_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_phone': doctorPhone,
      'old_schedule_id': oldScheduleId,
      'old_day': oldDay,
      'old_start_time': oldStartTime,
      'old_end_time': oldEndTime,
      'new_day': newDay,
      'new_start_time': newStartTime,
      'new_end_time': newEndTime,
      'reason': reason,
      'status': status.value,
      'admin_approver_id': adminApproverId,
      'rejection_reason': rejectionReason,
      'created_at': FieldValue.serverTimestamp(),
      'approved_at': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }
}
