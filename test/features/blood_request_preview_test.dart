import 'package:damy/core/router/app_router.dart';
import 'package:damy/core/theme/app_theme.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('request preview keeps edits and confirms without saving', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = createRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
    router.go('/blood-request');
    await tester.pumpAndSettle();
    await tester.tap(find.text('AB+'));
    await tester.tap(find.byTooltip('زيادة عدد الأكياس'));
    await tester.ensureVisible(find.byKey(const ValueKey('request-hospital')));
    await tester.enterText(
      find.byKey(const ValueKey('request-hospital')),
      'مستشفى تجريبي',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'معاينة الطلب'));
    await tester.pumpAndSettle();
    expect(find.text('AB+'), findsWidgets);
    expect(find.text('4 أكياس دم مطلوبة'), findsOneWidget);
    expect(find.text('مستشفى تجريبي'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('تعديل البيانات'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('تعديل البيانات'));
    await tester.pumpAndSettle();
    final hospital = tester.widget<TextField>(
      find.byKey(const ValueKey('request-hospital')),
    );
    expect(hospital.controller!.text, 'مستشفى تجريبي');
    await tester.tap(find.widgetWithText(ElevatedButton, 'معاينة الطلب'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('تأكيد المعاينة'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('تأكيد المعاينة'));
    await tester.pumpAndSettle();
    expect(find.text('معاينة الطلب جاهزة'), findsOneWidget);
    expect(find.textContaining('لم يتم نشر أو حفظ الطلب'), findsOneWidget);
    await tester.tap(find.text('عرض طلباتي'));
    await tester.pumpAndSettle();
    expect(find.text('بيانات تجريبية · للعرض فقط'), findsOneWidget);
    expect(find.text('مستشفى تجريبي'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
