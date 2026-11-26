import 'package:damy/app.dart';
import 'package:damy/features/profile/presentation/cubit/profile_cubit.dart';
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

  testWidgets('profile language switches interface and API header', (
    tester,
  ) async {
    final (backend, _) = await boot(tester);
    await tester.tap(find.text(t.myAccountTab).last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(t.languageLabel), 200);
    await Scrollable.ensureVisible(
      tester.element(find.text(t.languageLabel)),
      alignment: 0.3,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.languageLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('App language'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('App language'))),
      TextDirection.ltr,
    );
    getIt<ProfileCubit>().load();
    await tester.pumpAndSettle();
    expect(
      backend.callsTo('GET /profile').last.headers['accept-language'],
      'en',
    );
  });

  testWidgets('profile shows server data and no invented fields', (
    tester,
  ) async {
    await boot(tester);
    await tester.tap(find.text(t.myAccountTab).last);
    await tester.pumpAndSettle();
    expect(find.text('أحمد'), findsOneWidget);
    expect(find.text('01012345678'), findsOneWidget);
  });

  testWidgets('profile offers my donations without the duplicate history row', (
    tester,
  ) async {
    final (backend, _) = await boot(tester);
    backend.on(
      'GET /pledges/mine',
      (_) => FakeReply({'items': [], 'nextCursor': null, 'hasMore': false}),
    );
    await tester.tap(find.text(t.myAccountTab).last);
    await tester.pumpAndSettle();
    expect(find.text(t.donationHistoryTitle), findsNothing);
    await tester.scrollUntilVisible(find.text(t.myDonationsTitle), 200);
    await Scrollable.ensureVisible(
      tester.element(find.text(t.myDonationsTitle)),
      alignment: 0.3,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.myDonationsTitle));
    await tester.pumpAndSettle();
    expect(find.text(t.myDonationsEmpty), findsOneWidget);
    expect(backend.callsTo('GET /pledges/mine'), hasLength(1));
    expect(backend.callsTo('GET /profile/donations'), isEmpty);
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
    await Scrollable.ensureVisible(tester.element(logout), alignment: 0.3);
    await tester.pumpAndSettle();
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
    await Scrollable.ensureVisible(tester.element(del), alignment: 0.3);
    await tester.pumpAndSettle();
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
