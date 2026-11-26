import 'dart:io';
import 'dart:ui' as ui;

import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/theme/app_theme.dart';
import 'package:damy/features/profile/presentation/pages/info_page.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

Future<void> _show(
  WidgetTester tester,
  FakeBackend backend,
  GlobalKey key,
) async {
  final tokens = MemoryTokenStore('saved');
  configureDependencies(tokens: tokens, api: backend.client(tokens));
  addTearDown(getIt.reset);
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const InfoPage(kind: ProfileInfo.privacy),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _shot(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage();
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory('build/shots').createSync(recursive: true);
    File('build/shots/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  Future<void> setup(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fonts = FontLoader('Cairo');
    for (final w in ['Regular', 'SemiBold', 'Bold', 'Black']) {
      fonts.addFont(rootBundle.load('assets/fonts/Cairo-$w.ttf'));
    }
    await fonts.load();
  }

  testWidgets('shows server content with the draft notice', (tester) async {
    await setup(tester);
    final backend = FakeBackend()
      ..on(
        'GET /content/privacy',
        (_) => FakeReply({
          'slug': 'privacy',
          'title': 'عنوان من السيرفر',
          'isDraft': true,
          'notice': 'ملاحظة المسودة من السيرفر',
          'sections': [
            {'id': 'a', 'heading': 'قسم أول', 'body': 'نص القسم الأول'},
          ],
        }),
      );
    final key = GlobalKey();
    await _show(tester, backend, key);
    expect(find.text('عنوان من السيرفر'), findsOneWidget);
    expect(find.text('قسم أول'), findsOneWidget);
    expect(find.text('ملاحظة المسودة من السيرفر'), findsOneWidget);
    expect(
      backend.callsTo('GET /content/privacy').single.headers['accept-language'],
      'ar',
    );
    await _shot(tester, key, 'content_server');
  });

  testWidgets('falls back to bundled draft text when the API fails', (
    tester,
  ) async {
    await setup(tester);
    final backend = FakeBackend();
    final key = GlobalKey();
    await _show(tester, backend, key);
    final t = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(t.privacyTitle), findsOneWidget);
    expect(find.text(t.policyDraftNotice), findsOneWidget);
    await _shot(tester, key, 'content_fallback');
  });
}
