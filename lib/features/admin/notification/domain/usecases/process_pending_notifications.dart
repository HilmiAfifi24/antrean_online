// import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class ProcessPendingNotifications {
  final NotificationRepository repository;

  ProcessPendingNotifications(this.repository);

  Future<void> call() async {
    final pendingNotifications = await repository.getPendingNotifications();
    
    for (final notification in pendingNotifications) {
      try {
        await repository.sendNotification(notification);
        await repository.markNotificationSent(notification.id);
      } catch (e) {
        await repository.markNotificationFailed(notification.id, e.toString());
      }
    }
  }
}
