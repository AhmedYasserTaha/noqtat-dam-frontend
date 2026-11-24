import 'package:damy/features/blood_request/data/models/blood_request_model.dart';
import 'package:damy/features/home_feed/presentation/widgets/feed_cards.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

int mineTaps = 0;

Future<void> _pump(WidgetTester tester, Map<String, dynamic> json) =>
    tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: UrgentRequestCard(
              request: BloodRequestModel.fromJson(json),
              onDonate: () {},
              onShare: () {},
              onViewMine: () => mineTaps++,
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('urgent card shows the hospital name and place', (tester) async {
    await _pump(tester, requestJson(hospital: 'مستشفى السنبلاوين العام'));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('urgent-hospital')),
        matching: find.text('مستشفى السنبلاوين العام'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('المنصورة'), findsWidgets);
    expect(find.byKey(const ValueKey('urgent-notes')), findsNothing);
  });

  testWidgets('urgent card shows notes when the requester wrote some', (
    tester,
  ) async {
    await _pump(tester, {
      ...requestJson(),
      'notes': 'الدور التالت، اسأل عن الاستقبال',
    });
    expect(find.text('الدور التالت، اسأل عن الاستقبال'), findsOneWidget);
  });

  testWidgets(
    'own urgent request says so instead of an unreadable donate button',
    (tester) async {
      await _pump(tester, requestJson(isMine: true));
      final t = AppLocalizations.of(
        tester.element(find.byType(UrgentRequestCard)),
      )!;
      expect(find.text(t.viewMyRequests), findsOneWidget);
      expect(find.text(t.iWillDonate), findsNothing);
      mineTaps = 0;
      await tester.tap(find.text(t.viewMyRequests));
      expect(mineTaps, 1);
    },
  );

  testWidgets('urgent card fits its content inside bounded height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Align(
          alignment: Alignment.topCenter,
          child: UrgentRequestCard(
            request: BloodRequestModel.fromJson(requestJson()),
            onDonate: () {},
            onShare: () {},
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(UrgentRequestCard)).height,
      lessThan(400),
    );
  });
}
