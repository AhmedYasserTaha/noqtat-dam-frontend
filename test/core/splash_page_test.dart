import 'package:damy/core/theme/app_theme.dart';
import 'package:damy/features/auth/presentation/pages/splash_page.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(VoidCallback onFinished, {bool reducedMotion = false}) =>
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reducedMotion),
          child: SplashPage(onFinished: onFinished),
        ),
      );

  testWidgets('splash shows branding and finishes its animation once', (
    tester,
  ) async {
    var finished = 0;
    await tester.pumpWidget(app(() => finished++));
    await tester.pump();
    final t = AppLocalizations.of(tester.element(find.byType(SplashPage)))!;
    expect(find.text(t.appName), findsOneWidget);
    expect(find.text(t.authTagline), findsOneWidget);
    expect(finished, 0);
    await tester.pump(const Duration(milliseconds: 700));
    expect(finished, 0);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 16));
    expect(finished, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(finished, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion finishes without waiting for animation', (
    tester,
  ) async {
    var finished = 0;
    await tester.pumpWidget(app(() => finished++, reducedMotion: true));
    await tester.pump();
    expect(finished, 1);
    expect(tester.takeException(), isNull);
  });
}
