// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init(String userId) async {
    try {
      await _messaging.requestPermission();

      // ✅ Canal de notificação com som
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notificações Mana Lanches',

        importance: Importance.max,

        playSound: true,

        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notificacao'),
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // ✅ Mostra notificação mesmo com app aberto
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      String? token = await _messaging.getToken();

      if (token != null) {
        await FirebaseFirestore.instance.collection("usuarios").doc(userId).set(
          {"fcmToken": token},
          SetOptions(merge: true),
        );
      }

      _messaging.onTokenRefresh.listen((newToken) {
        FirebaseFirestore.instance.collection("usuarios").doc(userId).set({
          "fcmToken": newToken,
        }, SetOptions(merge: true));
      });

      // ✅ App aberto
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final android = message.notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'Notificações Mana Lanches',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
                sound: RawResourceAndroidNotificationSound('notificacao'),
              ),
            ),
          );
        }
      });
    } catch (e) {
      print("Erro FCM: $e");
    }
  }
}
