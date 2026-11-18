import 'dart:io';
import 'dart:ui' as ui;

import 'package:damy/core/router/app_shell.dart';
import 'package:damy/core/theme/app_theme.dart';
import 'package:damy/core/widgets/app_bottom_nav.dart';
import 'package:damy/features/home_feed/presentation/pages/home_feed_page.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('home filters, independent navigation and narrow layout work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fonts = FontLoader('Cairo');
    for (final weight in ['Regular', 'SemiBold', 'Bold', 'Black']) {
      fonts.addFont(rootBundle.load('assets/fonts/Cairo-$weight.ttf'));
    }
    await fonts.load();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              AppShell(location: state.uri.path, child: child),
          routes: [
            GoRoute(path: '/', builder: (_, state) => const HomeFeedPage()),
            GoRoute(
              path: '/map',
              builder: (_, state) => const PendingTabPage(title: 'الخريطة'),
            ),
            GoRoute(
              path: '/requests',
              builder: (_, state) => const PendingTabPage(title: 'طلباتي'),
            ),
            GoRoute(
              path: '/profile',
              builder: (_, state) => const PendingTabPage(title: 'حسابي'),
            ),
          ],
        ),
        GoRoute(
          path: '/blood-request',
          builder: (_, state) => const Scaffold(body: Text('Create request')),
        ),
      ],
    );
    addTearDown(router.dispose);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('دم الخير'),
      findsOneWidget,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .join(' | '),
    );
    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(tester.takeException(), isNull);
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/home-preview.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });

    await tester.ensureVisible(find.text('فصيلتي'));
    await tester.tap(find.text('فصيلتي'));
    await tester.pumpAndSettle();
    expect(find.text('كيسين دم'), findsNothing);
    expect(
      find.text('الطلب المميز فوق مطابق لفصيلتك التجريبية O-'),
      findsOneWidget,
    );

    await tester.tap(find.text('الخريطة'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppBottomNav>(find.byType(AppBottomNav)).selected,
      AppNavDestination.map,
    );
    await tester.tap(find.text('طلباتي'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppBottomNav>(find.byType(AppBottomNav)).selected,
      AppNavDestination.requests,
    );
    await tester.tap(find.byTooltip('إنشاء طلب دم'));
    await tester.pumpAndSettle();
    expect(find.text('Create request'), findsOneWidget);
    router.go('/');
    tester.view.physicalSize = const Size(320, 640);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('قريب مني'));
    await tester.tap(find.text('قريب مني'));
    await tester.pumpAndSettle();
    expect(find.text('كيسين دم'), findsNothing);
    expect(find.text('كيس صفائح دموية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
