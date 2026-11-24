import 'dart:async';

import '../network/api_client.dart';
import 'push_service.dart';

/// Keeps the backend's copy of this device's push token in step with the
/// signed-in user: register after sign-in, follow token rotation, and clear
/// it before sign-out so the next person on this phone does not get the
/// previous account's notifications.
class PushRegistrar {
  PushRegistrar(this._push, this._api);
  final PushService _push;
  final ApiClient _api;
  StreamSubscription<String>? _refresh;
  String? _token;

  Future<void> onSignedIn() async {
    final token = await _push.register();
    if (token != null) await _send(token);
    unawaited(_refresh?.cancel());
    _refresh = _push.tokenRefreshes.listen(_send);
  }

  Future<void> beforeSignOut() async {
    unawaited(_refresh?.cancel());
    _refresh = null;
    if (_token == null) return;
    try {
      await _api.patch('/me', body: {'fcmToken': null});
    } catch (_) {
      // Best effort: an expired session cannot clear it either.
    }
    _token = null;
  }

  Future<void> _send(String token) async {
    try {
      await _api.patch('/me', body: {'fcmToken': token});
      _token = token;
    } catch (_) {
      // Retried at the next sign-in or token refresh.
    }
  }
}
