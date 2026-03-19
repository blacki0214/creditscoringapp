import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    print('[Push] Background message received: ${message.messageId}');
  }
}

class PushNotificationService {
  PushNotificationService._internal();
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'credit_scoring_high_importance',
    'Credit Scoring Notifications',
    description: 'Notifications for loan updates and account alerts.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();
    await _requestPermission();
    await _syncFcmTokenToCurrentUser();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    _messaging.onTokenRefresh.listen((token) async {
      await _saveTokenForCurrentUser(token);
    });

    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _syncFcmTokenToCurrentUser();
      }
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }

    _initialized = true;
    if (kDebugMode) {
      print('[Push] PushNotificationService initialized');
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    if (kDebugMode) {
      print('[Push] Permission status: ${settings.authorizationStatus}');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) {
          print('[Push] Local notification tapped: ${details.payload}');
        }
      },
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_defaultChannel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('[Push] Foreground message: ${message.messageId}');
    }

    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      message.hashCode,
      notification.title ?? 'Notification',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    if (kDebugMode) {
      print('[Push] Message tapped/opened: ${message.data}');
    }

    // TODO: Route navigation based on message.data['type'] if needed.
  }

  Future<String?> getFcmToken() async {
    return _messaging.getToken();
  }

  Future<void> showScoringResultNotification({
    required bool approved,
    required int creditScore,
    double? loanAmount,
  }) async {
    final formattedAmount = _currencyFormat.format(loanAmount ?? 0);
    final title = approved
      ? 'Scoring Complete | Được phê duyệt'
      : 'Scoring Complete | Không được phê duyệt';
    final body = approved
      ? 'Score: $creditScore | Hạn mức: $formattedAmount'
      : 'Score: $creditScore | Vui lòng kiểm tra lại hồ sơ.';

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode({
        'type': approved ? 'loan_approved' : 'loan_rejected',
        'creditScore': creditScore,
        'loanAmount': loanAmount ?? 0,
      }),
    );

    if (kDebugMode) {
      print('[Push] Scoring result notification shown (approved: $approved)');
    }
  }

  Future<void> _syncFcmTokenToCurrentUser() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _saveTokenForCurrentUser(token);
  }

  Future<void> _saveTokenForCurrentUser(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      'fcmPlatform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (kDebugMode) {
      print('[Push] Saved FCM token for user: ${user.uid}');
    }
  }
}
