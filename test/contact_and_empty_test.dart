import 'dart:io';
import 'dart:ui' as ui;

import 'package:damy/app.dart';
import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/utils/egypt_locations.dart';
import 'package:damy/features/home_feed/presentation/widgets/pledge_sheet.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';
import 'hospital_directory_test.dart' show FakeMaps;

void main() {
  final t = lookupAppLocalizations(const Locale('ar'));

  test('phone links', () {
    expect(callUri('0109 999-8888').toString(), 'tel:01099998888');
    expect(whatsappUri('01099998888').toString(), 'https://wa.me/201099998888');
    expect(
      whatsappUri('+201099998888').toString(),
      'https://wa.me/201099998888',
    );
    expect(
      whatsappUri('00201099998888').toString(),
      'https://wa.me/201099998888',
    );
    expect(whatsappUri('123'), isNull);
  });

  Future<GlobalKey> fonts(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final f = FontLoader('Cairo');
    for (final w in ['Regular', 'SemiBold', 'Bold', 'Black']) {
      f.addFont(rootBundle.load('assets/fonts/Cairo-$w.ttf'));
    }
    await f.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    await tester.runAsync(() => EgyptLocations.load());
    return GlobalKey();
  }

  Future<void> shot(WidgetTester tester, GlobalKey key, String name) async {
    await tester.pumpAndSettle();
    final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await b.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/shots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('pledge sheet offers call and WhatsApp', (tester) async {
    final key = await fonts(tester);
    final backend = FakeBackend();
    stubHome(
      backend,
      requests: [requestJson(id: 8, hospital: 'مستشفى المنصورة')],
    );
    backend.on(
      'POST /requests/8/pledge',
      (_) => FakeReply(
        requestJson(
          id: 8,
          hospital: 'مستشفى المنصورة',
          contactPhone: '01099998888',
          myPledgeStatus: 'on_the_way',
        ),
      ),
    );
    final tokens = MemoryTokenStore('saved');
    final maps = FakeMaps();
    configureDependencies(
      tokens: tokens,
      api: backend.client(tokens),
      maps: maps,
    );
    await tester.pumpWidget(RepaintBoundary(key: key, child: const DamyApp()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(t.iWillDonate).first);
    await tester.tap(find.text(t.iWillDonate).first);
    await tester.pumpAndSettle();
    await shot(tester, key, 'contact-pledge-sheet');
    await tester.tap(find.byKey(const ValueKey('contact-call')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('contact-whatsapp')));
    await tester.pumpAndSettle();
    expect(maps.opened, [
      'link:tel:01099998888',
      'link:https://wa.me/201099998888',
    ]);
    expect(find.text('01099998888'), findsOneWidget); // copy button stays
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiple urgent requests scroll horizontally', (tester) async {
    await fonts(tester);
    final backend = FakeBackend();
    stubHome(
      backend,
      requests: [
        requestJson(id: 11, hospital: 'Urgent one'),
        requestJson(id: 12, hospital: 'Urgent two'),
      ],
    );
    final tokens = MemoryTokenStore('saved');
    configureDependencies(tokens: tokens, api: backend.client(tokens));
    await tester.pumpWidget(const DamyApp());
    await tester.pumpAndSettle();
    final strip = find.byKey(const Key('urgent-requests-scroll'));
    await tester.ensureVisible(strip);
    final before = tester.getTopLeft(find.text('Urgent two')).dx;
    await tester.drag(strip, const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Urgent two')).dx, greaterThan(before));
    expect(find.text('Urgent one'), findsOneWidget);
    expect(find.text('Urgent two'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty filter offers a way out', (tester) async {
    final key = await fonts(tester);
    final backend = FakeBackend();
    stubHome(backend);
    backend.on(
      'GET /home',
      (_) => FakeReply({
        'readiness': {
          'isAvailable': true,
          'lastDonationAt': null,
          'donationsCount': 0,
          'selfReported': true,
        },
        'closestUrgentRequest': requestJson(id: 9),
        'requests': [],
        'posts': [],
        'unreadNotifications': 0,
      }),
    );
    backend.on('GET /requests', (o) {
      final f = o.queryParameters['filter'];
      final empty = f != null && f != 'all';
      return FakeReply({
        'items': empty
            ? <Object?>[]
            : [requestJson(id: 8, hospital: 'مستشفى المنصورة')],
        'nextBefore': null,
        'nextCursor': null,
      });
    });
    final tokens = MemoryTokenStore('saved');
    configureDependencies(tokens: tokens, api: backend.client(tokens));
    await tester.pumpWidget(RepaintBoundary(key: key, child: const DamyApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.filterMyBlood));
    await tester.pumpAndSettle();
    expect(find.text(t.noRequestsFiltered), findsOneWidget);
    await shot(tester, key, 'empty-filter');
    await tester.tap(find.byKey(const Key('empty-show-all')));
    await tester.pumpAndSettle();
    expect(find.text(t.noRequestsFiltered), findsNothing);
    expect(find.textContaining('مستشفى المنصورة'), findsWidgets);
    await tester.tap(find.text(t.filterNearby));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('empty-change-area')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
