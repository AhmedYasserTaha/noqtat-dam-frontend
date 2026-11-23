import 'package:damy/core/router/app_router.dart';
import 'package:damy/core/theme/app_theme.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'static profile, policies and request tabs work on small screens',
    (tester) async {
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      router.go('/profile');
      await tester.pumpAndSettle();
      expect(find.text('محمد أحمد'), findsOneWidget);
      await tester.tap(find.text('تعديل الملف الشخصي'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'أحمد علي');
      await tester.tap(find.text('حفظ للمعاينة'));
      await tester.pumpAndSettle();
      expect(find.text('أحمد علي'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('سياسة الخصوصية'), 300);
      await tester.tap(find.text('سياسة الخصوصية'));
      await tester.pumpAndSettle();
      expect(find.text('البيانات في النسخة الحالية'), findsOneWidget);
      expect(tester.takeException(), isNull);
      router.pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('الشروط والأحكام'));
      await tester.tap(find.text('الشروط والأحكام'));
      await tester.pumpAndSettle();
      expect(find.text('الغرض من التطبيق'), findsOneWidget);
      router.go('/requests');
      await tester.pumpAndSettle();
      expect(find.text('كيسين دم'), findsOneWidget);
      await tester.tap(find.text('مكتملة'));
      await tester.pumpAndSettle();
      expect(find.text('كيس صفائح دموية'), findsOneWidget);
      expect(find.text('كيسين دم'), findsNothing);
      await tester.tap(find.text('ملغية'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تفاصيل الطلب'));
      await tester.pumpAndSettle();
      expect(find.textContaining('طلب تجريبي لعرض'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
