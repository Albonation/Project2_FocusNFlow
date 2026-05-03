import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initialize() async {
    await _requestPermission();
    await _saveCurrentToken();

    _messaging.onTokenRefresh.listen((token) {
      _saveToken(token);
    });

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'FocusNFlow';
      final body = message.notification?.body ?? '';

      debugPrint('[FCM_FOREGROUND] $title - $body');
      debugPrint('[FCM_DATA] ${message.data}');
    });
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  Future<void> _saveCurrentToken() async {
    final token = await _messaging.getToken();

    if (token == null || token.trim().isEmpty) {
      debugPrint('[FCM] No token available yet.');
      return;
    }

    debugPrint('[FCM] Token: $token');
    await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;

    if (user == null || token.trim().isEmpty) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('[FCM] Token saved for user ${user.uid}');
  }
}
