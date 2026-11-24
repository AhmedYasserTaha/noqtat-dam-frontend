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
}
