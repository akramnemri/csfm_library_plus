import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.initialize();
  await NotificationService.instance.showNotification(
    title: message.notification?.title ?? 'CSFM Library+',
    body: message.notification?.body ?? '',
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Local notifications setup
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // Create notification channel
    const channel = AndroidNotificationChannel(
      'csfm_notifications',
      'CSFM Library+ Notifications',
      description: 'Rappels et alertes de la bibliothèque',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground FCM messages
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(
        title: message.notification?.title ?? 'CSFM Library+',
        body: message.notification?.body ?? '',
      );
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler);

    _initialized = true;
  }

  // Show immediate local notification
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'csfm_notifications',
          'CSFM Library+ Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // Notify when a book becomes available
  Future<void> notifyDisponible(String documentTitre) async {
    await showNotification(
      title: '📚 Document disponible !',
      body: '"$documentTitre" est maintenant disponible.',
    );
  }

  // Notify return reminder
  Future<void> notifyRetourRappel(
      String documentTitre, int joursRestants) async {
    final message = joursRestants == 0
        ? 'Le retour de "$documentTitre" est prévu aujourd\'hui !'
        : joursRestants < 0
            ? '"$documentTitre" est en retard de '
                '${joursRestants.abs()} jour(s).'
            : 'Il reste $joursRestants jour(s) pour retourner '
                '"$documentTitre".';

    await showNotification(
      title: joursRestants < 0 ? '⚠️ Retour en retard !' : '🔔 Rappel de retour',
      body: message,
      id: documentTitre.hashCode,
    );
  }

  // Save FCM token to Firestore
  Future<void> saveTokenToFirestore(String userId) async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});
    } catch (e) {
      // Silently fail — not critical
    }
  }

  // Get FCM token (for admin use / testing)
  Future<String?> getToken() => _fcm.getToken();
}