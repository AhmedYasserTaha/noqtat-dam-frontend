import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/features/blood_request/presentation/pages/my_donations_page.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';
import 'hospital_directory_test.dart' show FakeMaps;

Map<String, dynamic> donation(
  int id, {
  String status = 'on_the_way',
  String requestStatus = 'open',
  String? phone,
}) => {
  'status': status,
  'createdAt': '2026-11-20T10:00:00Z',
  'updatedAt': '2026-11-21T10:00:00Z',
  'request': requestJson(
    id: id,
    hospital: 'Hospital $id',
    status: requestStatus,
    contactPhone: phone,
    myPledgeStatus: status,
  ),
};

void main() {
  late AppLocalizations t;
  setUpAll(
    () async => t = await AppLocalizations.delegate.load(const Locale('ar')),
  );

  Future<void> boot(
    WidgetTester tester,
    FakeBackend backend, {
    FakeMaps? maps,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final tokens = MemoryTokenStore('saved');
    configureDependencies(
      tokens: tokens,
      api: backend.client(tokens),
      maps: maps,
    );
    addTearDown(getIt.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const MyDonationsPage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('server filters and cursor pagination preserve previous cards', (
    tester,
  ) async {
    final backend = FakeBackend();
    backend.on('GET /pledges/mine', (o) {
      if (o.queryParameters['status'] == 'cancelled') {
        return FakeReply({
          'items': <Object?>[],
          'nextCursor': null,
          'hasMore': false,
        });
      }
      final more = o.queryParameters['cursor'] != null;
      return FakeReply({
        'items': [donation(more ? 2 : 1)],
        'nextCursor': more ? null : 'opaque:2',
        'hasMore': !more,
      });
    });
    await boot(tester, backend);
    final first = backend.callsTo('GET /pledges/mine').single;
    expect(first.query, {'status': 'all', 'limit': 20});
    expect(first.headers['authorization'], 'Bearer saved');
    expect(find.text('Hospital 1'), findsOneWidget);
    await tester.tap(find.text(t.loadMore));
    await tester.pumpAndSettle();
    expect(find.text('Hospital 1'), findsOneWidget);
    expect(find.text('Hospital 2'), findsOneWidget);
    expect(
      backend.callsTo('GET /pledges/mine').last.query['cursor'],
      'opaque:2',
    );
    await tester.ensureVisible(
      find.byKey(const Key('donations-filter-cancelled')),
    );
    await tester.tap(find.byKey(const Key('donations-filter-cancelled')));
    await tester.pumpAndSettle();
    expect(find.text(t.myDonationsEmpty), findsOneWidget);
    expect(backend.callsTo('GET /pledges/mine').last.query, {
      'status': 'cancelled',
      'limit': 20,
    });
  });

  testWidgets(
    'contact opens dialer and donated updates API then refreshes filter',
    (tester) async {
      final backend = FakeBackend();
      final maps = FakeMaps();
      var donated = false;
      backend.on(
        'GET /pledges/mine',
        (o) => FakeReply({
          'items': donated && o.queryParameters['status'] == 'on_the_way'
              ? <Object?>[]
              : [donation(7, phone: '01099998888')],
          'nextCursor': null,
          'hasMore': false,
        }),
      );
      backend.on('PATCH /requests/7/pledge', (_) {
        donated = true;
        return FakeReply(requestJson(id: 7, myPledgeStatus: 'donated'));
      });
      await boot(tester, backend, maps: maps);
      await tester.tap(find.byKey(const Key('donations-filter-on_the_way')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.requestDetails));
      await tester.pumpAndSettle();
      expect(find.text('01099998888'), findsOneWidget);
      await tester.tap(find.text(t.callRequester));
      await tester.pumpAndSettle();
      expect(maps.opened, ['link:tel:01099998888']);
      await tester.tap(find.widgetWithText(FilledButton, t.donationRecorded));
      await tester.pumpAndSettle();
      expect(backend.callsTo('PATCH /requests/7/pledge').single.body, {
        'status': 'donated',
      });
      expect(find.text(t.myDonationsEmpty), findsOneWidget);
    },
  );

  testWidgets(
    'failures can retry; cancelled contacts and closed actions stay hidden',
    (tester) async {
      final backend = FakeBackend();
      var fail = true;
      backend.on(
        'GET /pledges/mine',
        (_) => fail
            ? FakeReply({'error': 'down'}, 500)
            : FakeReply({
                'items': [
                  donation(
                    9,
                    status: 'cancelled',
                    requestStatus: 'fulfilled',
                    phone: '01099998888',
                  ),
                ],
                'nextCursor': null,
                'hasMore': false,
              }),
      );
      await boot(tester, backend);
      expect(find.text(t.myDonationsEmpty), findsNothing);
      fail = false;
      await tester.tap(find.text(t.retry));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.requestDetails));
      await tester.pumpAndSettle();
      expect(find.text(t.donationClosed), findsOneWidget);
      expect(find.text('01099998888'), findsNothing);
      expect(find.text(t.callRequester), findsNothing);
      expect(
        find.widgetWithText(FilledButton, t.donationRecorded),
        findsNothing,
      );
    },
  );
}
