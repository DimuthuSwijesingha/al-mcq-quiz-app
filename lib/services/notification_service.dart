import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> showReminderNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'mcq_reminder_channel',
      'MCQ Reminders',
      channelDescription: 'Reminds user to practice MCQs',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Time to practice!',
      'You moved away from home. Check your MCQ skills 💡',
      notificationDetails,
    );
  }
}
