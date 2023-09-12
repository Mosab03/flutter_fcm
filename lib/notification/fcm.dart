import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'local_notification.dart';

class FCM {
  FCM._();

  static late ValueChanged<String?> _onTokenChanged;

  static initializeFCM(
      {required void onTokenChanged(String? token),
      void onNotificationPressed(Map<String, dynamic> data)?,
      required BackgroundMessageHandler onNotificationReceived,
      GlobalKey<NavigatorState>? navigatorKey,
      required String icon,
      bool withLocalNotification = true}) async {
    _onTokenChanged = onTokenChanged;
    await LocalNotification.initializeLocalNotification(
        onNotificationPressed: onNotificationPressed, icon: icon);
    await Firebase.initializeApp();
    FirebaseMessaging.instance.getToken().then(onTokenChanged);
    Stream<String> _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(onTokenChanged);

// Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(onNotificationReceived);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      print('getInitialMessage');
      print(message.toString());
      if (message != null) {
        if (navigatorKey != null)
          Timer.periodic(
            Duration(milliseconds: 500),
            (timer) {
              if (navigatorKey.currentState == null) return;
              onNotificationPressed!(message.data);
              timer.cancel();
            },
          );
      }
    });

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        print('A new onMessage event was published!');

        onNotificationReceived(message);
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        print('Happy');
        print(notification.toString());
        print(android.toString());
        print(withLocalNotification);
        if (notification != null && android != null && withLocalNotification) {
          await LocalNotification.showNotification(
              notification: notification, payload: message.data, icon: icon);
          print('axxx');
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      onNotificationPressed!(message.data);
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      print('A new onBackgroundMessage event was published!');
      onNotificationPressed!(message.data);
      onNotificationReceived(message);
    });
  }

//static Future<void> _firebaseMessagingBackgroundHandler
  static deleteRefreshToken() {
    FirebaseMessaging.instance.deleteToken();
    FirebaseMessaging.instance.getToken().then(_onTokenChanged);
  }
}
