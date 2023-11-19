import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  /// Create a [AndroidNotificationChannel] for heads up notifications
  static AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    // 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  static AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  static DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  static initializeLocalNotification(
      {void onNotificationPressed(Map<String, dynamic> data)?,
      required String icon}) async {
    // Create an Android notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: (notificationResponse) {
        onDidReceiveNotificationResponse(
          notificationResponse: notificationResponse,
          onData: onNotificationPressed,
        );
      },
      onDidReceiveNotificationResponse: (notificationResponse) {
        onDidReceiveNotificationResponse(
            notificationResponse: notificationResponse,
            onData: onNotificationPressed);
      },
    );
  }

  static Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    debugPrint(title);
  }

  static showNotification(
      {required RemoteNotification notification,
      Map<String, dynamic>? payload,
      String? icon}) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: icon,
        ),
      ),
      payload: jsonEncode(payload),
    );
  }
}

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
    {required NotificationResponse notificationResponse, onData}) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
    var jsonData = jsonDecode(payload!);
    onData(jsonData);
  }
}
