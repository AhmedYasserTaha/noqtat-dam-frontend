import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/features/blood_request/presentation/cubit/my_requests_cubit.dart';
import 'package:damy/features/blood_request/presentation/pages/my_requests_page.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

void main() {
  Future<void> open(WidgetTester tester, FakeBackend backend) async {
    final tokens = MemoryTokenStore('test-token');
    configureDependencies(tokens: tokens, api: backend.client(tokens));
    addTearDown(getIt.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: getIt<MyRequestsCubit>(),
          child: const Scaffold(body: MyRequestsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty account loads all requests in one call and shows create', (
    tester,
  ) async {
    final backend = FakeBackend();
    backend.on('GET /requests/mine', (_) => FakeReply({'items': <Object?>[]}));
    await open(tester, backend);
    final t = AppLocalizations.of(tester.element(find.byType(MyRequestsPage)))!;
    expect(find.widgetWithText(ChoiceChip, t.filterAll), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, t.createRequestAction),
      findsOneWidget,
    );
    expect(backend.callsTo('GET /requests/mine').single.query, {'tab': 'all'});
  });

  testWidgets('existing requests hide create even on an empty status filter', (
    tester,
  ) async {
    final backend = FakeBackend();
    backend.on(
      'GET /requests/mine',
      (options) => FakeReply({
        'items':
            options.queryParameters['tab'] == 'all' ||
                options.queryParameters['tab'] == 'active'
            ? [requestJson(id: 1, isMine: true)]
            : <Object?>[],
      }),
    );
    await open(tester, backend);
    final t = AppLocalizations.of(tester.element(find.byType(MyRequestsPage)))!;
    expect(find.text(t.requestDetails), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, t.createRequestAction),
      findsNothing,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, t.requestCancelled));
    await tester.pumpAndSettle();
    expect(find.text(t.noRequestsYet), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, t.createRequestAction),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'self-reported donors are separate; confirming asks first, then adds one bag once',
    (tester) async {
      final backend = FakeBackend();
      var confirmed = false;
      Map<String, dynamic> current() => requestJson(
        id: 1,
        isMine: true,
        needed: 3,
        collected: confirmed ? 2 : 1,
        selfReported: confirmed ? 0 : 1,
        confirmed: confirmed ? 1 : 0,
      );
      backend.on(
        'GET /requests/mine',
        (_) => FakeReply({
          'items': [current()],
        }),
      );
      backend.on(
        'GET /requests/1/pledges',
        (_) => FakeReply([
          {
            'donorId': 5,
            'donorName': 'منى',
            'bloodType': 'B-',
            'status': 'donated',
            'confirmed': confirmed,
            'createdAt': '2026-11-24T10:00:00.000Z',
            'updatedAt': '2026-11-24T11:00:00.000Z',
          },
        ]),
      );
      backend.on('POST /requests/1/pledges/5/confirm', (_) {
        confirmed = true;
        return FakeReply(current());
      });
      await open(tester, backend);
      final t = AppLocalizations.of(
        tester.element(find.byType(MyRequestsPage)),
      )!;
      // card: self-report line, count still the requester's own number
      expect(find.byKey(const Key('self-reported-1')), findsOneWidget);
      expect(find.textContaining('1 / 3'), findsOneWidget);

      await tester.tap(find.text(t.requestDetails));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-donation-5')));
      await tester.pumpAndSettle();
      // nothing is sent until the requester agrees
      expect(backend.callsTo('POST /requests/1/pledges/5/confirm'), isEmpty);
      expect(find.text(t.confirmDonationBody('منى', 1, 2)), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm-donation-yes')));
      await tester.pumpAndSettle();

      expect(backend.callsTo('POST /requests/1/pledges/5/confirm').length, 1);
      // sheet refreshed: new count, confirmed label, no confirm button left
      expect(find.text(t.pledgeConfirmedByYou), findsOneWidget);
      expect(find.byKey(const Key('confirm-donation-5')), findsNothing);
      expect(find.byKey(const Key('self-reported-1')), findsNothing);
      expect(find.text('2'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a donor already counted by the requester edit adds nothing', (
    tester,
  ) async {
    final backend = FakeBackend();
    backend.on(
      'GET /requests/mine',
      (_) => FakeReply({
        'items': [
          requestJson(
            id: 1,
            isMine: true,
            needed: 3,
            collected: 1,
            selfReported: 1,
          ),
        ],
      }),
    );
    backend.on(
      'GET /requests/1/pledges',
      (_) => FakeReply([
        {
          'donorId': 5,
          'donorName': 'منى',
          'bloodType': 'B-',
          'status': 'donated',
          'confirmed': false,
          'addsToCount': false,
          'createdAt': '2026-11-24T10:00:00.000Z',
          'updatedAt': '2026-11-24T11:00:00.000Z',
        },
      ]),
    );
    await open(tester, backend);
    final t = AppLocalizations.of(tester.element(find.byType(MyRequestsPage)))!;
    await tester.tap(find.text(t.requestDetails));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-donation-5')));
    await tester.pumpAndSettle();
    expect(
      find.text(t.confirmDonationAlreadyCounted('منى', 1)),
      findsOneWidget,
    );
  });

  testWidgets('a covered open request tells the author to close it', (
    tester,
  ) async {
    final backend = FakeBackend();
    backend.on(
      'GET /requests/mine',
      (_) => FakeReply({
        'items': [requestJson(id: 1, isMine: true, needed: 2, collected: 2)],
      }),
    );
    backend.on('GET /requests/1/pledges', (_) => FakeReply(<Object?>[]));
    await open(tester, backend);
    final t = AppLocalizations.of(tester.element(find.byType(MyRequestsPage)))!;
    await tester.tap(find.text(t.requestDetails));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('covered-hint')), findsOneWidget);
    // closing is still the author's own choice
    expect(backend.callsTo('PATCH /requests/1'), isEmpty);
  });
}
