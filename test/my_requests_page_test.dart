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
    'self-reported donors never change the count; the requester raises it with +',
    (tester) async {
      final backend = FakeBackend();
      var collected = 1;
      Map<String, dynamic> current() => requestJson(
        id: 1,
        isMine: true,
        needed: 3,
        collected: collected,
        selfReported: 1,
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
            'donorName': 'منى',
            'bloodType': 'B-',
            'status': 'donated',
            'createdAt': '2026-11-24T10:00:00.000Z',
            'updatedAt': '2026-11-24T11:00:00.000Z',
          },
        ]),
      );
      backend.on('PATCH /requests/1', (call) {
        collected = (call.data as Map)['bagsCollected'] as int;
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
      // the donor is listed, with no confirm button and no dialog
      expect(find.text('منى'), findsOneWidget);
      expect(find.text(t.pledgeDonated), findsOneWidget);
      expect(backend.callsTo('PATCH /requests/1'), isEmpty);

      await tester.tap(find.byTooltip(t.increaseBags));
      await tester.pumpAndSettle();
      expect(backend.callsTo('PATCH /requests/1').single.body, {
        'bagsCollected': 2,
      });
      // the sheet stays open and shows the new number
      expect(find.text('2'), findsWidgets);
      await tester.tap(find.byTooltip(t.decreaseBags));
      await tester.pumpAndSettle();
      expect(backend.callsTo('PATCH /requests/1').last.body, {
        'bagsCollected': 1,
      });
      expect(tester.takeException(), isNull);
    },
  );

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
