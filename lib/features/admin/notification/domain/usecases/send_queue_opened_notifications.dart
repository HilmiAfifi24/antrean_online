import '../repositories/notification_repository.dart';

class SendQueueOpenedNotifications {
  final NotificationRepository repository;

  SendQueueOpenedNotifications(this.repository);

  Future<void> call(String scheduleId) async {
    await repository.createQueueOpenedNotifications(scheduleId);
  }
}
