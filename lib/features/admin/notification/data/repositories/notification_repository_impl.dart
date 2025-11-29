import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.firestore,
  });

  @override
  Future<List<NotificationEntity>> getPendingNotifications() async {
    return await remoteDataSource.getPendingNotifications();
  }

  @override
  Future<void> sendNotification(NotificationEntity notification) async {
    await remoteDataSource.sendWhatsAppMessage(
      notification.recipientPhone,
      notification.message,
    );
  }

  @override
  Future<void> markNotificationSent(String notificationId) async {
    await remoteDataSource.updateNotificationStatus(notificationId, true);
  }

  @override
  Future<void> markNotificationFailed(String notificationId, String error) async {
    await remoteDataSource.updateNotificationStatus(notificationId, false, errorMessage: error);
  }

  @override
  Future<void> createQueueOpenedNotifications(String scheduleId) async {
    // Get schedule details
    final scheduleDoc = await firestore.collection('schedules').doc(scheduleId).get();
    if (!scheduleDoc.exists) {
      throw Exception('Schedule not found');
    }

    final scheduleData = scheduleDoc.data()!;
    final doctorName = scheduleData['doctor_name'] as String;
    
    // Get today's date
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    // Get all queues for this schedule today
    final queuesSnapshot = await firestore
        .collection('queues')
        .where('schedule_id', isEqualTo: scheduleId)
        .where('appointment_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointment_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();
    
    // print('Creating queue opened notifications for ${queuesSnapshot.docs.length} queues');
    
    for (final queueDoc in queuesSnapshot.docs) {
      final queueData = queueDoc.data();
      
      // Get patient details
      final patientId = queueData['patient_id'] as String;
      final patientDoc = await firestore.collection('users').doc(patientId).get();
      
      if (!patientDoc.exists) continue;
      
      final patientData = patientDoc.data()!;
      final patientName = patientData['name'] as String;
      final patientPhone = patientData['phone'] as String?;
      
      if (patientPhone == null || patientPhone.isEmpty) {
        // print('Patient $patientName has no phone number, skipping');
        continue;
      }
      
      final queueNumber = queueData['queue_number'] as int;
      
      final message = '''
🏥 *Antrean Dibuka*

Halo $patientName,

Antrean Anda untuk *Dr. $doctorName* telah dibuka!

📋 Nomor Antrean: *$queueNumber*
📅 Tanggal: ${_formatDate(today)}

Silakan datang tepat waktu ke klinik.

_Sistem Antrean Online_
      '''.trim();

      final notification = NotificationEntity(
        id: firestore.collection('notifications').doc().id,
        type: 'queue_opened',
        recipientPhone: patientPhone,
        recipientName: patientName,
        message: message,
        scheduleId: scheduleId,
        doctorName: doctorName,
        scheduledTime: DateTime.now(),
      );

      await remoteDataSource.saveNotification(notification);
      
      // Send immediately
      try {
        await sendNotification(notification);
        await markNotificationSent(notification.id);
        // print('Notification sent to $patientName ($patientPhone)');
      } catch (e) {
        await markNotificationFailed(notification.id, e.toString());
        // print('Failed to send notification to $patientName: $e');
      }
    }
  }

  @override
  Future<void> createPracticeStartedNotifications(String scheduleId) async {
    // Get schedule details
    final scheduleDoc = await firestore.collection('schedules').doc(scheduleId).get();
    if (!scheduleDoc.exists) {
      throw Exception('Schedule not found');
    }

    final scheduleData = scheduleDoc.data()!;
    final doctorName = scheduleData['doctor_name'] as String;
    
    // Get today's date
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    // Get all queues for this schedule today with status 'menunggu'
    final queuesSnapshot = await firestore
        .collection('queues')
        .where('schedule_id', isEqualTo: scheduleId)
        .where('appointment_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointment_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: 'menunggu')
        .get();
    
    // print('Creating practice started notifications for ${queuesSnapshot.docs.length} waiting queues');
    
    for (final queueDoc in queuesSnapshot.docs) {
      final queueData = queueDoc.data();
      
      // Get patient details
      final patientId = queueData['patient_id'] as String;
      final patientDoc = await firestore.collection('users').doc(patientId).get();
      
      if (!patientDoc.exists) continue;
      
      final patientData = patientDoc.data()!;
      final patientName = patientData['name'] as String;
      final patientPhone = patientData['phone'] as String?;
      
      if (patientPhone == null || patientPhone.isEmpty) {
        // print('Patient $patientName has no phone number, skipping');
        continue;
      }
      
      final queueNumber = queueData['queue_number'] as int;
      
      final message = '''
🏥 *Praktek Dimulai*

Halo $patientName,

Praktek *Dr. $doctorName* telah dimulai!

📋 Nomor Antrean: *$queueNumber*
📅 Tanggal: ${_formatDate(today)}

Mohon segera datang ke klinik untuk pemeriksaan.

_Sistem Antrean Online_
      '''.trim();

      final notification = NotificationEntity(
        id: firestore.collection('notifications').doc().id,
        type: 'practice_started',
        recipientPhone: patientPhone,
        recipientName: patientName,
        message: message,
        scheduleId: scheduleId,
        doctorName: doctorName,
        scheduledTime: DateTime.now(),
      );

      await remoteDataSource.saveNotification(notification);
      
      // Send immediately
      try {
        await sendNotification(notification);
        await markNotificationSent(notification.id);
        // print('Notification sent to $patientName ($patientPhone)');
      } catch (e) {
        await markNotificationFailed(notification.id, e.toString());
        // print('Failed to send notification to $patientName: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
