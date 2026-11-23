import 'dart:io';
import 'dart:ui' as ui;

import 'package:damy/core/theme/app_theme.dart';
import 'package:damy/features/auth/presentation/pages/auth_page.dart';
import 'package:damy/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:damy/features/auth/presentation/pages/register_page.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'auth forms navigate without validation and fit a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fonts = FontLoader('Cairo');
      for (final name in ['Regular', 'SemiBold', 'Bold', 'Black']) {
        fonts.addFont(rootBundle.load('assets/fonts/Cairo-$name.ttf'));
      }
      await fonts.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final router = GoRouter(
        initialLocation: '/auth',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => const Scaffold(body: Text('Home preview')),
          ),
          GoRoute(path: '/auth', builder: (_, state) => const AuthPage()),
          GoRoute(
            path: '/auth/register',
            builder: (_, state) => const RegisterPage(),
          ),
          GoRoute(
            path: '/auth/forgot-password',
            builder: (_, state) => const ForgotPasswordPage(),
          ),
        ],
      );
      addTearDown(router.dispose);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('أهلاً بيك تاني'), findsOneWidget);
      expect(tester.takeException(), isNull);

      for (final size in [const Size(390, 844), const Size(360, 740)]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        final scroll = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        expect(
          scroll.position.maxScrollExtent,
          0,
          reason: 'Login should fit $size',
        );
      }
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();

      Future<void> capture(String name) async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('build/auth-previews/$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('login');
      await tester.tap(find.text('نسيت كلمة السر؟'));
      await tester.pumpAndSettle();
      expect(find.text('إرسال كود الاسترجاع'), findsOneWidget);
      await capture('recovery');
      await tester.tap(find.text('إرسال كود الاسترجاع'));
      await tester.pumpAndSettle();
      expect(find.text('اكتب رقم موبايل مصري صحيح'), findsNothing);

      router.go('/auth/register');
      await tester.pumpAndSettle();
      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
      await capture('register');
      await tester.ensureVisible(find.text('كمّل'));
      await tester.tap(find.text('كمّل'));
      await tester.pumpAndSettle();
      expect(find.text('Home preview'), findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpAndSettle();
      router.go('/auth');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('سجّل دلوقتي'));
      await tester.tap(find.text('سجّل دلوقتي'));
      await tester.pumpAndSettle();
      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
