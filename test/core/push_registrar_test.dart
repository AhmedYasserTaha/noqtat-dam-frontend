import 'dart:async';

import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/utils/push_registrar.dart';
import 'package:damy/core/utils/push_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_backend.dart';

class TestPush implements PushService {
  final changes = StreamController<String>.broadcast();
  int registrations = 0;
  @override
  Future<String?> register() async {
    registrations++;
    return 'initial';
  }

  @override
  Stream<String> get tokenRefreshes => changes.stream;
  @override
  Stream<void> get foregroundMessages => const Stream.empty();
}

void main() {
  test(
    'registers once, ignores duplicate events and sends a rotated token',
    () async {
      final backend = FakeBackend();
      backend.on('PATCH /fcm-token', (_) => FakeReply({'ok': true}));
      final push = TestPush();
      final registrar = PushRegistrar(
        push,
        backend.client(MemoryTokenStore('session')),
      );
      addTearDown(push.changes.close);
      await Future.wait([registrar.onSignedIn(), registrar.onSignedIn()]);
      await registrar.onSignedIn();
      expect(push.registrations, 1);
      expect(backend.callsTo('PATCH /fcm-token'), hasLength(1));
      push.changes.add('initial');
      push.changes.add('rotated');
      push.changes.add('rotated');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(backend.callsTo('PATCH /fcm-token').map((c) => c.body), [
        {'fcmToken': 'initial'},
        {'fcmToken': 'rotated'},
      ]);
      await registrar.beforeSignOut();
      expect(backend.calls.last.body, {'fcmToken': null});
      await registrar.onSignedIn();
      expect(push.registrations, 2);
      expect(backend.calls.last.body, {'fcmToken': 'initial'});
      await registrar.beforeSignOut();
    },
  );

  test(
    'a failed registration can retry instead of being cached as sent',
    () async {
      final backend = FakeBackend();
      var attempts = 0;
      backend.on(
        'PATCH /fcm-token',
        (_) => ++attempts == 1
            ? FakeReply({'error': 'unavailable'}, 503)
            : FakeReply({'ok': true}),
      );
      final push = TestPush();
      final registrar = PushRegistrar(
        push,
        backend.client(MemoryTokenStore('session')),
      );
      addTearDown(push.changes.close);
      await registrar.onSignedIn();
      await registrar.onSignedIn();
      await registrar.onSignedIn();
      expect(attempts, 2);
      await registrar.beforeSignOut();
    },
  );
}
