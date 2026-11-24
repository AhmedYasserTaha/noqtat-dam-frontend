import 'dart:io';
import 'dart:ui' as ui;

import 'package:damy/app.dart';
import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/utils/device_location.dart';
import 'package:damy/core/utils/egypt_locations.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

class FakeLocation implements DeviceLocation {
  FakeLocation(this.result);
  final DeviceLocationResult result;
  int calls = 0;
  @override
  Future<DeviceLocationResult> current() async {
    calls++;
    return result;
  }
}

Map<String, dynamic> withPin(Map<String, dynamic> j, double lat, double lon) =>
    {
      ...j,
      'hospitalLocation': {
        'latitude': lat,
        'longitude': lon,
        'isVerified': false,
        'dataCredit': 'openstreetmap',
      },
    };

void main() {
  final t = lookupAppLocalizations(const Locale('ar'));

  test('distanceKm is a plausible great-circle distance', () {
    // Mansoura to Cairo is roughly 105 to 125 km in a straight line.
    final d = distanceKm(31.0409, 31.3785, 30.0444, 31.2357);
    expect(d, inInclusiveRange(105, 125));
    expect(distanceKm(31, 31, 31, 31), 0);
  });

  Future<GlobalKey> setup(WidgetTester tester, FakeLocation loc) async {
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
    final backend = FakeBackend();
    stubHome(
      backend,
      requests: [
        withPin(requestJson(id: 1, hospital: 'مستشفى القاهرة', urgency: 'scheduled'), 30.04, 31.23),
        requestJson(id: 2, hospital: 'مستشفى بدون موقع', urgency: 'scheduled'),
        withPin(requestJson(id: 3, hospital: 'مستشفى المنصورة', urgency: 'scheduled'), 31.04, 31.38),
      ],
    );
    final tokens = MemoryTokenStore('saved');
    configureDependencies(tokens: tokens, api: backend.client(tokens), location: loc);
    return GlobalKey();
  }

  double top(WidgetTester tester, String text) =>
      tester.getTopLeft(find.textContaining(text).first).dy;

  testWidgets('opt-in sort puts the closest hospital first, unpinned last', (tester) async {
    final loc = FakeLocation(const DeviceLocationResult.ok(31.05, 31.37));
    final key = await setup(tester, loc);
    await tester.pumpWidget(RepaintBoundary(key: key, child: const DamyApp()));
    await tester.pumpAndSettle();
    // Nothing asks for location until the user taps.
    expect(loc.calls, 0);
    // default order: Cairo, no-pin, Mansoura
    expect(top(tester, 'مستشفى القاهرة') < top(tester, 'مستشفى المنصورة'), isTrue);
    await tester.tap(find.byKey(const Key('sort-distance')));
    await tester.pumpAndSettle();
    expect(loc.calls, 1);
    final m = top(tester, 'مستشفى المنصورة');
    final c = top(tester, 'مستشفى القاهرة');
    final n = top(tester, 'مستشفى بدون موقع');
    expect(m < c && c < n, isTrue);
    expect(find.byKey(const Key('distance-label')), findsNWidgets(2));
    // both pins are unreviewed: the label must say so
    expect(find.textContaining('الموقع غير مراجع'), findsNWidgets(2));
    final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await b.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/shots/distance-sorted.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
    // tap again: back to default order, no second permission request
    await tester.tap(find.byKey(const Key('sort-distance')));
    await tester.pumpAndSettle();
    expect(top(tester, 'مستشفى القاهرة') < top(tester, 'مستشفى المنصورة'), isTrue);
    expect(loc.calls, 1);
    expect(tester.takeException(), isNull);
  });

  for (final o in [LocationOutcome.denied, LocationOutcome.deniedForever, LocationOutcome.serviceOff, LocationOutcome.failed]) {
    testWidgets('location $o keeps default order and offers the area picker', (tester) async {
      final loc = FakeLocation(DeviceLocationResult.failed(o));
      final key = await setup(tester, loc);
      await tester.pumpWidget(RepaintBoundary(key: key, child: const DamyApp()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sort-distance')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(t.changeMyArea), findsOneWidget);
      expect(find.byKey(const Key('distance-label')), findsNothing);
      expect(top(tester, 'مستشفى القاهرة') < top(tester, 'مستشفى المنصورة'), isTrue);
    });
  }
}
