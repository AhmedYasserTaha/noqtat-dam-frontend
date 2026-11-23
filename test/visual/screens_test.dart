// Renders the real screens (real fonts, real Cubits, fake backend) and saves
// PNGs to build/shots/. Run: flutter test test/visual
import 'dart:io';
import 'dart:ui' as ui;

import 'package:damy/app.dart';
import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/utils/egypt_locations.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_backend.dart';

void main() {
  testWidgets('screens render and the create flow publishes', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final t = await AppLocalizations.delegate.load(const Locale('ar'));
    final fonts = FontLoader('Cairo');
    for (final w in ['Regular', 'SemiBold', 'Bold', 'Black']) {
      fonts.addFont(rootBundle.load('assets/fonts/Cairo-$w.ttf'));
    }
    await fonts.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    await tester.runAsync(() => EgyptLocations.load());

    final backend = FakeBackend();
    final urgent = requestJson(id: 8, hospital: 'مستشفى المنصورة الجامعي');
    final other = requestJson(
      id: 7,
      bloodType: 'A+',
      urgency: 'within_24h',
      hospital: 'مستشفى طلخا العام',
      needed: 2,
      collected: 0,
    );
    backend.on('GET /me', (_) => FakeReply(meJson()));
    backend.on('GET /me/donations', (_) => FakeReply(<Object?>[]));
    backend.on(
      'GET /home',
      (_) => FakeReply({
        'readiness': {
          'isAvailable': true,
          'lastDonationAt': '2026-07-23T10:00:00.000Z',
          'donationsCount': 3,
          'selfReported': true,
        },
        'closestUrgentRequest': urgent,
        'requests': [urgent, other],
        'posts': [
          {
            'id': 1,
            'authorId': 3,
            'authorName': 'محمد',
            'text': 'تبرعت النهارده وحاسس بسعادة كبيرة.',
            'createdAt': '2026-11-23T08:00:00.000Z',
          },
        ],
      }),
    );
    backend.on(
      'GET /requests',
      (_) => FakeReply({
        'items': [urgent, other],
        'nextBefore': null,
      }),
    );
    backend.on(
      'GET /requests/mine',
      (_) => FakeReply({
        'items': [requestJson(id: 20, isMine: true, hospital: 'مستشفى الاختبار')],
        'nextBefore': null,
      }),
    );
    backend.on('POST /requests', (_) => FakeReply(requestJson(id: 20), 201));
    final tokens = MemoryTokenStore();
    configureDependencies(tokens: tokens, api: backend.client(tokens));
    backend.on(
      'POST /auth/login',
      (_) => FakeReply({
        'token': 'tok',
        'user': {
          'id': 1,
          'name': 'أحمد',
          'phone': '01012345678',
          'bloodType': 'O-',
        },
      }),
    );

    final key = GlobalKey();
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final f = File('build/shots/$name.png');
        await f.parent.create(recursive: true);
        await f.writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }

    await tester.pumpWidget(RepaintBoundary(key: key, child: const DamyApp()));
    await tester.pumpAndSettle();
    await shot('01-login');

    // wrong input shows validation
    final button = find.widgetWithText(ElevatedButton, t.loginAction);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await shot('02-login-validation');

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '01012345678');
    await tester.enterText(fields.at(1), 'password1');
    await tester.tap(button);
    await shot('03-home');

    await tester.tap(find.text(t.myRequestsTab).last);
    await shot('04-my-requests');
    await tester.tap(find.text(t.requestDetails));
    await shot('05-request-details');
    await tester.tap(find.text(t.closeLocations));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.myAccountTab).last);
    await shot('06-profile');

    // create request, full happy path with the location picker
    await tester.tap(find.byTooltip(t.createRequestAction).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('AB+'));
    await tester.tap(find.byTooltip(t.increaseBags));
    await tester.ensureVisible(find.byKey(const ValueKey('request-hospital')));
    await tester.enterText(
      find.byKey(const ValueKey('request-hospital')),
      'مستشفى الاختبار',
    );
    await tester.runAsync(() => EgyptLocations.load());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('governorate')));
    await tester.tap(find.byKey(const ValueKey('governorate')));
    await tester.pumpAndSettle();
    await shot('07-governorate-picker');
    await tester.enterText(find.byType(TextField).last, 'الدقهلية');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'الدقهلية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.selectDistrict));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'المنصورة');
    await tester.pumpAndSettle();
    await tester.tap(find.text('مركز المنصورة'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('request-phone')));
    await tester.enterText(
      find.byKey(const ValueKey('request-phone')),
      '01012345678',
    );
    await shot('08-create-filled');
    await tester.tap(find.widgetWithText(ElevatedButton, t.reviewRequestTitle));
    await shot('09-create-review');
    await tester.scrollUntilVisible(
      find.text(t.confirmRequestPreview),
      250,
      scrollable: find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text(t.confirmRequestPreview));
    await shot('10-create-published');
    final body = backend.callsTo('POST /requests').single.body as Map;
    expect(body['bloodType'], 'AB+');
    expect(body['bagsNeeded'], 4);
    expect(body['governorateId'], isNotNull);
    expect(body['districtId'], isNotNull);
    expect(body['contactPhone'], '01012345678');
    expect(tester.takeException(), isNull);
  });
}
