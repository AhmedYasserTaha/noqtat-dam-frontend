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

  Future<void> boot(WidgetTester tester) async {
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
  }

  testWidgets('system back on /profile or /requests returns to home /', (
    tester,
  ) async {
    await boot(tester);
    final element = tester.element(find.byType(Scaffold).first);

    GoRouter.of(element).go('/profile');
    await tester.pumpAndSettle();
    expect(find.text(t.editProfileTitle), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(t.editProfileTitle), findsNothing);

    GoRouter.of(element).go('/requests');
    await tester.pumpAndSettle();
    expect(find.text(t.myRequestsTab), findsWidgets);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(t.editProfileTitle), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
