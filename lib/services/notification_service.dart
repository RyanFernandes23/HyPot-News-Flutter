import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import '../core/providers/settings_provider.dart';

final notificationProvider = Provider((ref) => NotificationService(ref));

class NotificationService {
  final Ref _ref;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  NotificationService(this._ref);

  Future<void> init() async {
    // Check user preference
    final prefs = _ref.read(settingsProvider);
    if (!prefs.notificationsEnabled) {
      print('Notifications are disabled in settings. Skipping FCM initialization.');
      return;
    }

    // Request permission (if not already granted in main)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
      
      // Get the token
      String? token = await _fcm.getToken();
      if (token != null) {
        await _syncToken(token);
      }

      // Listen for token refreshes
      _fcm.onTokenRefresh.listen(_syncToken);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.notification?.title}');
        // We handle this silently as per requirements: no banners.
        // If we want to update some specific local state, we can do it here.
      });

      // Handle notification taps (app was in background but still running)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification tapped: ${message.notification?.title}');
        // TODO: Handle navigation to the briefing or article
      });
    } else {
      print('User declined or has not yet granted notification permission');
    }
  }

  Future<void> _syncToken(String token) async {
    print('FCM Token: $token');
    try {
      await _ref.read(authServiceProvider).updateFcmToken(token);
    } catch (e) {
      print('Error syncing FCM token with backend: $e');
    }
  }
}
