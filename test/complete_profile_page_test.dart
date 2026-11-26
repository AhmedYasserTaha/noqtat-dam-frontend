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
    String? governorateId,
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
        'bloodType': 'O+',
        'governorateId': governorateId,
        'governorate': null,
        'districtId': null,
        'district': null,
      }),
    );
    backend.on(
      'PATCH /profile',
      (call) => FakeReply({
        ...meJson(),
        'bloodType': (call.data as Map)['bloodType'] as String? ?? 'O+',
        'governorateId': (call.data as Map)['governorateId'] as String?,
        'isAvailable': (call.data as Map)['isAvailable'] as bool? ?? true,
      }),
    );
    final tokens = MemoryTokenStore('saved');
    configureDependencies(tokens: tokens, api: backend.client(tokens));
    await tester.pumpWidget(const DamyApp());
    await tester.pumpAndSettle();
    return (backend, tokens);
  }

  testWidgets(
    'complete profile validates governorate and saves PATCH /profile',
    (tester) async {
      final (backend, _) = await boot(tester);
      final element = tester.element(find.byType(Scaffold).first);
      GoRouter.of(element).go('/complete-profile');
      await tester.pumpAndSettle();

      expect(find.text(t.completeProfile), findsOneWidget);
      expect(find.text(t.placeholder), findsNothing);

      // Tapping save without governorate shows validation snackbar.
      await tester.tap(find.widgetWithText(ElevatedButton, t.saveChanges));
      await tester.pumpAndSettle();
      expect(find.text(t.errNeedGovernorate), findsOneWidget);
      expect(backend.callsTo('PATCH /profile'), isEmpty);

      // Pick blood type and governorate, then save.
      await tester.tap(find.text('AB+'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('governorate')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'الدقهلية');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'الدقهلية'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, t.saveChanges));
      await tester.pumpAndSettle();

      final patch = backend.callsTo('PATCH /profile').single.body as Map;
      expect(patch['bloodType'], 'AB+');
      expect(patch['governorateId'], isNotNull);
      expect(patch['isAvailable'], true);
      expect(find.text(t.completeProfile), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
