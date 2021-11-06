import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails? androifPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'channel_id', //Required for Android 8.0 or after
    'channel_name', //Required for Android 8.0 or after
    'Channel notification for entry', //Required for Android 8.0 or after
    importance: Importance(4),
  );

  static Future _notificationDetails() async {
    return NotificationDetails(androifPlatformChannelSpecifics, null);
  }

//  static Future init({bool initScheduled = false}) async{
//    final android =  AndroidInitializationSettings('app_icon');
//    final settings = InitializationSettings(android)
//  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(),
      );
}
