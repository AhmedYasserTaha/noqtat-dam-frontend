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
        'governorateId': governorateId ?? 'EG01',
        'governorate': {'id': 'EG01', 'ar': 'الدقهلية', 'en': 'Dakahlia'},
        'districtId': 'EG0101',
        'district': {'id': 'EG0101', 'ar': 'المنصورة', 'en': 'Mansoura'},
      }),
    );
    backend.on(
      'PATCH /profile',
      (call) => FakeReply({
        ...meJson(),
        'name': (call.data as Map)['name'] as String? ?? meJson()['name'],
        'phone': (call.data as Map)['phone'] as String? ?? meJson()['phone'],
        'bloodType': (call.data as Map)['bloodType'] as String? ?? 'O+',
        'governorateId': (call.data as Map)['governorateId'] as String? ?? 'EG01',
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
    'navigating to /profile and tapping editProfileTitle opens EditProfilePage with prefilled fields',
    (tester) async {
      await boot(tester);
      final element = tester.element(find.byType(Scaffold).first);
      GoRouter.of(element).go('/profile');
      await tester.pumpAndSettle();

      expect(find.text(t.myAccountTab), findsWidgets);
      await tester.tap(find.widgetWithText(OutlinedButton, t.editProfileTitle));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text(t.editProfileTitle), findsOneWidget);
      expect(find.widgetWithText(TextFormField, t.fullName), findsOneWidget);
      expect(find.widgetWithText(TextFormField, t.mobileNumber), findsOneWidget);
      expect(find.text('أحمد'), findsOneWidget);
      expect(find.text('01012345678'), findsOneWidget);
    },
  );

  testWidgets(
    'editing name and tapping save sends PATCH /profile and shows profileSaved snackbar',
    (tester) async {
      final (backend, _) = await boot(tester);
      final element = tester.element(find.byType(Scaffold).first);
      GoRouter.of(element).go('/profile');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, t.editProfileTitle));
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, t.fullName);
      await tester.enterText(nameField, 'محمد');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, t.saveChanges));
      await tester.pumpAndSettle();

      final patch = backend.callsTo('PATCH /profile').single.body as Map;
      expect(patch['name'], 'محمد');
      expect(patch['bloodType'], 'O+');
      expect(patch['governorateId'], 'EG01');
      expect(patch['isAvailable'], true);

      expect(find.text(t.myAccountTab), findsWidgets);
      expect(find.text(t.profileSaved), findsOneWidget);
    },
  );
}