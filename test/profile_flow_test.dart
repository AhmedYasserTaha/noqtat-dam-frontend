import 'package:damy/app.dart';
import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

void main() {
  late AppLocalizations t;
  setUpAll(() async {
    t = await AppLocalizations.delegate.load(const Locale('ar'));
  });

  Future<(FakeBackend, MemoryTokenStore)> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final backend = FakeBackend();
    stubHome(backend);
    final tokens = MemoryTokenStore('saved');
    configureDependencies(tokens: tokens, api: backend.client(tokens));
    await tester.pumpWidget(const DamyApp());
    await tester.pumpAndSettle();
    return (backend, tokens);
  }

  testWidgets('profile shows server data and no invented fields', (
    tester,
  ) async {
    await boot(tester);
    await tester.tap(find.text(t.myAccountTab).last);
    await tester.pumpAndSettle();
    expect(find.text('أحمد'), findsOneWidget);
    expect(find.text('01012345678'), findsOneWidget);
  });

  testWidgets('donations API runs only when donation history is opened', (
    tester,
  ) async {
    final (backend, _) = await boot(tester);
    backend.on(
      'GET /profile/donations',
      (_) => FakeReply([
        {
          'requestId': 7,
          'donatedAt': '2026-11-01T10:00:00.000Z',
          'bloodType': 'O+',
          'hospitalName': 'History hospital',
        },
      ]),
    );
    expect(backend.callsTo('GET /profile/donations'), isEmpty);
    await tester.tap(find.text(t.myAccountTab).last);
    await tester.pumpAndSettle();
    expect(backend.callsTo('GET /profile/donations'), isEmpty);
    await tester.scrollUntilVisible(find.text(t.donationHistoryTitle), 200);
    await tester.tap(find.text(t.donationHistoryTitle));
    await tester.pumpAndSettle();
    expect(backend.callsTo('GET /profile/donations'), hasLength(1));
    expect(find.textContaining('History hospital'), findsOneWidget);
    expect(find.textContaining(t.staticAccountPreview), findsNothing);
  });

  testWidgets('availability toggle patches the server', (tester) async {
    final (backend, _) = await boot(tester);
    backend.on('PATCH /profile', (_) => FakeReply(meJson(isAvailable: false)));
    await tester.tap(find.text(t.myAccountTab).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(backend.callsTo('PATCH /profile').single.body, {
      'isAvailable': false,
    });
  });

  testWidgets('logout clears the token and returns to login', (tester) async {
    final (_, tokens) = await boot(tester);
    await tester.tap(find.text(t.myAccountTab).last);
    await tester.pumpAndSettle();
    final logout = find.text(t.logoutAction);
    await tester.scrollUntilVisible(logout, 300);
    await tester.tap(logout);
    await tester.pumpAndSettle();
    expect(find.text(t.welcomeBack), findsOneWidget);
    expect(await tokens.read(), isNull);
  });

  testWidgets('delete account calls DELETE /profile then returns to login', (
    tester,
  ) async {
    final (backend, tokens) = await boot(tester);
    backend.on('DELETE /profile', (_) => FakeReply({'ok': true}));
    await tester.tap(find.text(t.myAccountTab).last);
    await tester.pumpAndSettle();
    final del = find.widgetWithText(TextButton, t.deleteAccountTitle);
    await tester.scrollUntilVisible(del, 300);
    await tester.tap(del);
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.deleteAccountConfirm));
    await tester.pumpAndSettle();
    expect(backend.callsTo('DELETE /profile'), hasLength(1));
    expect(find.text(t.welcomeBack), findsOneWidget);
    expect(await tokens.read(), isNull);
  });

  testWidgets('my requests loads from the API and author can fulfil', (
    tester,
  ) async {
    final (backend, _) = await boot(tester);
    backend.on(
      'GET /requests/mine',
      (_) => FakeReply({
        'items': [requestJson(id: 20, isMine: true, hospital: 'مستشفى طلبي')],
        'nextBefore': null,
      }),
    );
    backend.on(
      'PATCH /requests/20',
      (_) => FakeReply(requestJson(id: 20, status: 'fulfilled')),
    );
    await tester.tap(find.text(t.myRequestsTab).last);
    await tester.pumpAndSettle();
    expect(find.textContaining('مستشفى طلبي'), findsOneWidget);
    await tester.tap(find.text(t.requestDetails));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.markFulfilled));
    await tester.pumpAndSettle();
    expect(backend.callsTo('PATCH /requests/20').single.body, {
      'status': 'fulfilled',
    });
  });
}
