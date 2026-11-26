import 'package:damy/core/di/injection.dart';
import 'package:damy/core/network/api_client.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/utils/failure_message.dart';
import 'package:damy/features/profile/presentation/pages/info_page.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

void main() {
  test('server error code and translated message are preserved', () async {
    final backend = FakeBackend();
    backend.on(
      'POST /requests',
      (_) => FakeReply({
        'error': 'request closed',
        'code': 'request_closed',
        'message': 'This request is closed.',
      }, 409),
    );
    final api = backend.client(MemoryTokenStore());
    try {
      await api.post('/requests');
      fail('Expected failure');
    } on ApiException catch (e) {
      expect(e.failure.code, 'request_closed');
      final t = await AppLocalizations.delegate.load(const Locale('en'));
      expect(failureMessage(t, e.failure), 'This request is closed.');
    }
  });

  testWidgets(
    'content loads on opening, retries and reloads in selected language',
    (tester) async {
      final backend = FakeBackend();
      var failRequest = true;
      backend.on('GET /content/privacy', (request) {
        if (failRequest) return FakeReply({'error': 'failed'}, 503);
        final english = request.queryParameters['lang'] == 'en';
        return FakeReply({
          'title': english ? 'Server privacy' : 'Privacy AR',
          'isDraft': true,
          'notice': 'Draft notice from server',
          'sections': [
            {
              'id': 'data',
              'heading': 'Data heading',
              'body': 'Server content body',
            },
          ],
        });
      });
      final tokens = MemoryTokenStore();
      configureDependencies(tokens: tokens, api: backend.client(tokens));
      addTearDown(getIt.reset);
      expect(backend.callsTo('GET /content/privacy'), isEmpty);
      Widget app(String language) => MaterialApp(
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const InfoPage(kind: ProfileInfo.privacy),
      );
      await tester.pumpWidget(app('ar'));
      await tester.pumpAndSettle();
      final t = await AppLocalizations.delegate.load(const Locale('ar'));
      failRequest = false;
      await tester.tap(find.text(t.retry));
      await tester.pumpAndSettle();
      expect(find.text('Draft notice from server'), findsOneWidget);
      expect(find.text('Server content body'), findsOneWidget);
      await tester.pumpWidget(app('en'));
      await tester.pumpAndSettle();
      expect(find.text('Server privacy'), findsOneWidget);
      expect(backend.callsTo('GET /content/privacy').last.query, {
        'lang': 'en',
      });
      expect(backend.callsTo('GET /content/privacy'), hasLength(3));
    },
  );

  testWidgets('help uses FAQ slug and published content has no draft banner', (
    tester,
  ) async {
    final backend = FakeBackend();
    backend.on(
      'GET /content/faq',
      (_) => FakeReply({
        'title': 'FAQ from server',
        'isDraft': false,
        'notice': null,
        'sections': [
          {'heading': 'Question', 'body': 'Answer'},
        ],
      }),
    );
    final tokens = MemoryTokenStore();
    configureDependencies(tokens: tokens, api: backend.client(tokens));
    addTearDown(getIt.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const InfoPage(kind: ProfileInfo.help),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Answer'), findsOneWidget);
    final t = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(t.policyDraftNotice), findsNothing);
  });
}
