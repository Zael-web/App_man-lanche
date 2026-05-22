import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init(String userId) async {
    try {
      await _messaging.requestPermission();

      String? token = await _messaging.getToken();

      if (token != null) {
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(userId)
            .set({
              "fcmToken": token,
            }, SetOptions(merge: true));
      }

      _messaging.onTokenRefresh.listen((newToken) {
        FirebaseFirestore.instance
            .collection("usuarios")
            .doc(userId)
            .set({
              "fcmToken": newToken,
            }, SetOptions(merge: true));
      });

    } catch (e) {
      print("Erro FCM: $e");
    }
  }
}