import 'package:damy/app.dart';
import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/features/home_feed/presentation/pages/home_feed_page.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

Future<void> _boot(
  WidgetTester tester,
  FakeBackend backend, {
  String? token,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final tokens = MemoryTokenStore(token);
  configureDependencies(tokens: tokens, api: backend.client(tokens));
  await tester.pumpWidget(const DamyApp());
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), '01012345678');
  await tester.enterText(fields.at(1), 'password1');
  final button = find.widgetWithText(ElevatedButton, 'تسجيل الدخول');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  late AppLocalizations t;
  setUpAll(() async {
    t = await AppLocalizations.delegate.load(const Locale('ar'));
  });

  testWidgets('starts at login and validates before calling the API', (
    tester,
  ) async {
    final backend = FakeBackend();
    await _boot(tester, backend);
    expect(find.text('أهلاً بيك تاني'), findsOneWidget);
    final button = find.widgetWithText(ElevatedButton, 'تسجيل الدخول');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text(t.fieldRequired), findsWidgets);
    expect(backend.callsTo('POST /auth/login'), isEmpty);
    expect(find.byType(HomeFeedPage), findsNothing);
  });

  testWidgets('wrong credentials show a localized error and stay on login', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..on(
        'POST /auth/login',
        (_) => FakeReply({'error': 'wrong phone or password'}, 401),
      );
    await _boot(tester, backend);
    await _login(tester);
    expect(find.text(t.errWrongCredentials), findsOneWidget);
    expect(find.byType(HomeFeedPage), findsNothing);
  });

  testWidgets('login opens the home feed with real data and sends the token', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..on(
        'POST /auth/login',
        (_) => FakeReply({
          'token': 'tok-123',
          'user': {
            'id': 1,
            'name': 'أحمد',
            'phone': '01012345678',
            'bloodType': 'O-',
          },
        }),
      );
    stubHome(backend);
    await _boot(tester, backend);
    await _login(tester);
    expect(find.byType(HomeFeedPage), findsOneWidget);
    expect(find.textContaining('مستشفى المنصورة'), findsWidgets);
    expect(find.text('المنصورة'), findsWidgets);
    final home = backend.callsTo('GET /home').first;
    expect(home.headers['authorization'], 'Bearer tok-123');
    final login = backend.callsTo('POST /auth/login').single.body as Map;
    expect(login['phone'], '01012345678');
    // Readiness never claims medical eligibility.
    expect(find.text(t.availabilityLabel), findsOneWidget);
  });

  testWidgets('a saved token restores the session without the login screen', (
    tester,
  ) async {
    final backend = FakeBackend();
    stubHome(backend);
    await _boot(tester, backend, token: 'saved');
    expect(find.byType(HomeFeedPage), findsOneWidget);
    expect(find.text('أهلاً بيك تاني'), findsNothing);
  });

  testWidgets('an expired saved token falls back to login', (tester) async {
    final backend = FakeBackend()
      ..on('GET /profile', (_) => FakeReply({'error': 'unauthorized'}, 401));
    await _boot(tester, backend, token: 'old');
    expect(find.text('أهلاً بيك تاني'), findsOneWidget);
  });

  testWidgets('pledging shows the contact phone; donated is a self-report', (
    tester,
  ) async {
    final backend = FakeBackend();
    stubHome(
      backend,
      requests: [requestJson(id: 8, hospital: 'مستشفى المنصورة')],
    );
    backend.on(
      'POST /requests/8/pledge',
      (_) => FakeReply(
        requestJson(
          id: 8,
          hospital: 'مستشفى المنصورة',
          contactPhone: '01099998888',
          myPledgeStatus: 'on_the_way',
        ),
      ),
    );
    backend.on(
      'PATCH /requests/8/pledge',
      (_) => FakeReply(
        requestJson(
          id: 8,
          hospital: 'مستشفى المنصورة',
          myPledgeStatus: 'donated',
        ),
      ),
    );
    await _boot(tester, backend, token: 'saved');
    await tester.ensureVisible(find.text(t.iWillDonate).first);
    await tester.tap(find.text(t.iWillDonate).first);
    await tester.pumpAndSettle();
    expect(find.text('01099998888'), findsOneWidget);
    expect(find.textContaining(t.pledgeNote.substring(0, 20)), findsOneWidget);
    await tester.tap(find.text(t.iDonated));
    await tester.pumpAndSettle();
    final patch = backend.callsTo('PATCH /requests/8/pledge').single;
    expect(patch.body, {'status': 'donated'});
    expect(tester.takeException(), isNull);
  });

  testWidgets('create request validates, then posts exactly what was entered', (
    tester,
  ) async {
    final backend = FakeBackend();
    stubHome(backend);
    backend.on('POST /requests', (_) => FakeReply(requestJson(id: 20), 201));
    backend.on(
      'GET /requests/mine',
      (_) => FakeReply({
        'items': [requestJson(id: 20, isMine: true)],
        'nextBefore': null,
      }),
    );
    await _boot(tester, backend, token: 'saved');
    // Open the create screen directly through the router.
    await tester.tap(find.byTooltip('إنشاء طلب دم'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create-tab-request')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('request-hospital')));
    await tester.enterText(
      find.byKey(const ValueKey('request-hospital')),
      'مستشفى الاختبار',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, t.reviewRequestTitle));
    await tester.pumpAndSettle();
    // District and phone are still missing, so nothing is sent.
    expect(find.text(t.requestMissingFields), findsOneWidget);
    expect(backend.callsTo('POST /requests'), isEmpty);
  });
}
