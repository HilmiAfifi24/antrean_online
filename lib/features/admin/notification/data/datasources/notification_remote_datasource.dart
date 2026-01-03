import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';
import '../models/fonnte_response_model.dart';

abstract class NotificationRemoteDataSource {
  Future<void> sendWhatsAppMessage(String phone, String message);
  Future<List<NotificationEntity>> getPendingNotifications();
  Future<void> saveNotification(NotificationEntity notification);
  Future<void> updateNotificationStatus(String notificationId, bool isSent, {String? errorMessage});
  Future<List<Map<String, dynamic>>> getQueuesBySchedule(String scheduleId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final String fonnteApiToken;
  final String fonnteBaseUrl;
  final http.Client client;
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl({
    required this.fonnteApiToken,
    required this.fonnteBaseUrl,
    required this.client,
    required this.firestore,
  });

  @override
  Future<void> sendWhatsAppMessage(String phone, String message) async {
    try {
      final url = Uri.parse('$fonnteBaseUrl/send');
      
      // Ensure phone number has proper format (without +)
      String formattedPhone = phone.replaceAll('+', '').replaceAll('-', '').replaceAll(' ', '');
      if (!formattedPhone.startsWith('62')) {
        if (formattedPhone.startsWith('0')) {
          formattedPhone = '62${formattedPhone.substring(1)}';
        } else {
          formattedPhone = '62$formattedPhone';
        }
      }

      // print('Sending WhatsApp to: $formattedPhone');
      
      final response = await client.post(
        url,
        headers: {
          'Authorization': fonnteApiToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'target': formattedPhone,
          'message': message,
          'countryCode': '62',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout: Server tidak merespons dalam 30 detik');
        },
      );

      // print('Fonnte Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to send WhatsApp message: ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      final fonnteResponse = FonnteResponseModel.fromJson(responseData);
      
      if (!fonnteResponse.status) {
        throw Exception('Fonnte API error: ${fonnteResponse.message}');
      }
    } on SocketException catch (e) {
      throw Exception('Tidak dapat terhubung ke server Fonnte: ${e.message}');
    } on HandshakeException catch (e) {
      throw Exception('SSL Handshake gagal: ${e.message}. Periksa koneksi internet atau gunakan jaringan berbeda');
    } on http.ClientException catch (e) {
      throw Exception('HTTP Client error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<NotificationEntity>> getPendingNotifications() async {
    final querySnapshot = await firestore
        .collection('notifications')
        .where('is_sent', isEqualTo: false)
        .where('scheduled_time', isLessThanOrEqualTo: Timestamp.now())
        .get();

    return querySnapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> saveNotification(NotificationEntity notification) async {
    final notificationModel = NotificationModel(
      id: notification.id,
      type: notification.type,
      recipientPhone: notification.recipientPhone,
      recipientName: notification.recipientName,
      message: notification.message,
      scheduleId: notification.scheduleId,
      doctorName: notification.doctorName,
      scheduledTime: notification.scheduledTime,
      sentAt: notification.sentAt,
      isSent: notification.isSent,
      errorMessage: notification.errorMessage,
    );

    await firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notificationModel.toFirestore());
  }

  @override
  Future<void> updateNotificationStatus(String notificationId, bool isSent, {String? errorMessage}) async {
    await firestore.collection('notifications').doc(notificationId).update({
      'is_sent': isSent,
      'sent_at': isSent ? FieldValue.serverTimestamp() : null,
      'error_message': errorMessage,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getQueuesBySchedule(String scheduleId) async {
    final querySnapshot = await firestore
        .collection('queues')
        .where('schedule_id', isEqualTo: scheduleId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}
