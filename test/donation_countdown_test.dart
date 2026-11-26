import 'package:damy/app.dart';
import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/fake_backend.dart';

void main() {
  late AppLocalizations t;
  setUpAll(() async {
    t = await AppLocalizations.delegate.load(const Locale('ar'));
  });

  Future<(FakeBackend, MemoryTokenStore)> boot(
    WidgetTester tester, {
    required String lastDonationAt,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final backend = FakeBackend();
    stubHome(backend);
    backend.on(
      'GET /profile',
      (_) => FakeReply({
        ...meJson(),
        'lastDonationAt': lastDonationAt,
      }),
    );
    final tokens = MemoryTokenStore('saved');
    configureDependencies(tokens: tokens, api: backend.client(tokens));
    await tester.pumpWidget(const DamyApp());
    await tester.pumpAndSettle();
    return (backend, tokens);
  }

  testWidgets(
    '20 days ago shows remaining 40 days and progress indicator',
    (tester) async {
      await boot(
        tester,
        lastDonationAt:
            DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      );
      final element = tester.element(find.byType(Scaffold).first);
      GoRouter.of(element).go('/profile');
      await tester.pumpAndSettle();

      expect(find.textContaining('متبقي'), findsWidgets);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    '70 days ago shows eligible to donate now',
    (tester) async {
      await boot(
        tester,
        lastDonationAt:
            DateTime.now().subtract(const Duration(days: 70)).toIso8601String(),
      );
      final element = tester.element(find.byType(Scaffold).first);
      GoRouter.of(element).go('/profile');
      await tester.pumpAndSettle();

      expect(find.textContaining('مؤهل للتبرع الآن'), findsOneWidget);
    },
  );
}
