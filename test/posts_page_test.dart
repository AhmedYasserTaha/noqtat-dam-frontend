import 'package:damy/app.dart';
import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

void main() {
  testWidgets(
    'account opens GET posts, retries failures and loads the next page',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(getIt.reset);
      final backend = FakeBackend();
      stubHome(backend);
      var attempts = 0;
      backend.on('GET /posts', (options) {
        if (++attempts == 1) return FakeReply({'error': 'unavailable'}, 503);
        if (options.queryParameters['before'] == '2') {
          return FakeReply({
            'items': [postJson(id: 1, text: 'Second page', isMine: true)],
            'nextBefore': null,
          });
        }
        return FakeReply({
          'items': [
            postJson(id: 2, text: 'First page', isMine: true),
            postJson(id: 3, text: 'Someone else'),
          ],
          'nextBefore': 2,
        });
      });
      final tokens = MemoryTokenStore('saved');
      configureDependencies(tokens: tokens, api: backend.client(tokens));
      await tester.pumpWidget(const DamyApp());
      await tester.pumpAndSettle();
      final t = await AppLocalizations.delegate.load(const Locale('ar'));
      await tester.tap(find.text(t.myAccountTab).last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text(t.postsTitle), 250);
      await tester.tap(find.text(t.postsTitle));
      await tester.pumpAndSettle();
      expect(find.text(t.retry), findsOneWidget);
      await tester.tap(find.text(t.retry));
      await tester.pumpAndSettle();
      expect(find.text('First page'), findsOneWidget);
      expect(find.text('Someone else'), findsNothing);
      await tester.tap(find.text(t.loadMore));
      await tester.pumpAndSettle();
      expect(find.text('Second page'), findsOneWidget);
      expect(backend.callsTo('GET /posts').last.query, {'before': '2'});
      expect(
        backend.callsTo('GET /posts').last.headers['authorization'],
        'Bearer saved',
      );
      expect(find.text(t.loadMore), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
