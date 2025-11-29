import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getPendingNotifications();
  Future<void> sendNotification(NotificationEntity notification);
  Future<void> markNotificationSent(String notificationId);
  Future<void> markNotificationFailed(String notificationId, String error);
  Future<void> createQueueOpenedNotifications(String scheduleId);
  Future<void> createPracticeStartedNotifications(String scheduleId);
}
