import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Push notifications behind an interface. Tests use [NoopPushService]; the
/// app uses [FirebasePushService]. Nothing here is verified on a real device
/// until the backend has a Firebase service account configured.
abstract interface class PushService {
  /// Asks permission (when needed) and returns the device token, or null when
  /// push is unavailable or declined.
  Future<String?> register();

  /// Fires with a new token whenever Firebase rotates it.
  Stream<String> get tokenRefreshes;

  /// Fires when a message arrives while the app is open, so the inbox and the
  /// badge can refresh.
  Stream<void> get foregroundMessages;
}

class NoopPushService implements PushService {
  const NoopPushService();
  @override
  Future<String?> register() async => null;
  @override
  Stream<String> get tokenRefreshes => const Stream.empty();
  @override
  Stream<void> get foregroundMessages => const Stream.empty();
}

class FirebasePushService implements PushService {
  FirebasePushService([FirebaseMessaging? messaging])
    : _m = messaging ?? FirebaseMessaging.instance;
  final FirebaseMessaging _m;

  @override
  Future<String?> register() async {
    try {
      final settings = await _m.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return null;
      }
      return await _m.getToken();
    } catch (_) {
      return null; // e.g. iOS without APNs setup: the app still works
    }
  }

  @override
  Stream<String> get tokenRefreshes => _m.onTokenRefresh;

  @override
  Stream<void> get foregroundMessages =>
      FirebaseMessaging.onMessage.map((_) {});
}
