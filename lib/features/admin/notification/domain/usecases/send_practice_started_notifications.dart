import '../repositories/notification_repository.dart';

class SendPracticeStartedNotifications {
  final NotificationRepository repository;

  SendPracticeStartedNotifications(this.repository);

  Future<void> call(String scheduleId) async {
    await repository.createPracticeStartedNotifications(scheduleId);
  }
}
