// Renders the donor-alert and follow-through screens with synthetic data
// (real fonts, real Cubits, fake backend) and saves PNGs to build/shots/.
// Run: flutter test test/visual/followup_screens_test.dart
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
  testWidgets('follow-through screens render', (tester) async {
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

    // The requester typed 1 by hand (Karim was already in that number).
    var collected = 1;
    Map<String, dynamic> mine() => requestJson(
      id: 20,
      isMine: true,
      hospital: 'مستشفى المنصورة الجامعي',
      needed: 3,
      collected: collected,
      selfReported: 2,
    );
    final backend = FakeBackend();
    stubHome(backend, unread: 2);
    backend.on(
      'GET /requests/mine',
      (_) => FakeReply({
        'items': [mine()],
      }),
    );
    Map<String, dynamic> pledge(String name) => {
      'donorName': name,
      'bloodType': 'B-',
      'status': 'donated',
      'createdAt': '2026-11-24T10:00:00.000Z',
      'updatedAt': '2026-11-24T11:00:00.000Z',
    };
    backend.on(
      'GET /requests/20/pledges',
      (_) => FakeReply([pledge('منى'), pledge('كريم')]),
    );
    backend.on('PATCH /requests/20', (call) {
      collected = (call.data as Map)['bagsCollected'] as int;
      return FakeReply(mine());
    });
    backend.on(
      'GET /me/notifications',
      (_) => FakeReply({
        'items': [
          {
            'id': 3,
            'type': 'new_request',
            'postId': 31,
            'title': 'عاجل: محتاجين متبرع B- في المنصورة',
            'body': '2 أكياس · مستشفى المنصورة الجامعي. وصلك لأن فصيلتك مطابقة وانت متاح للتبرع في محافظتك.',
            'read': false,
            'createdAt': '2026-11-24T10:00:00.000Z',
          },
          {
            'id': 2,
            'type': 'pledge_update',
            'postId': 20,
            'title': '2 متبرع سجّلوا تبرعهم',
            'body': 'ده إقرار منهم ومش متحقق منه. أكّد اللي اتأكدت منه عشان العدد يتحدّث، وباقي 2 من 3 (B- · مستشفى المنصورة الجامعي).',
            'read': false,
            'createdAt': '2026-11-24T09:00:00.000Z',
          },
          {
            'id': 1,
            'type': 'request_status',
            'postId': 20,
            'title': 'لسه محتاج متبرعين؟',
            'body': 'طلب (B- · مستشفى المنصورة الجامعي) باقي فيه 2 من 3. حدّث عدد الأكياس أو اقفل الطلب لو اتغطى.',
            'read': true,
            'createdAt': '2026-11-23T09:00:00.000Z',
          },
        ],
        'unreadCount': 2,
        'nextBefore': null,
      }),
    );
    backend.on('POST /me/notifications/read', (_) => FakeReply({'ok': true}));
    final tokens = MemoryTokenStore('saved');
    configureDependencies(tokens: tokens, api: backend.client(tokens));

    final key = GlobalKey();
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final f = File('build/shots/followup-$name.png');
        await f.parent.create(recursive: true);
        await f.writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }

    await tester.pumpWidget(RepaintBoundary(key: key, child: const DamyApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bell-badge')));
    await shot('1-notifications');
    // tapping the reminder opens my requests, like the real app
    await tester.tap(find.byKey(const Key('notification-2')));
    await shot('2-my-requests-card');
    await tester.tap(find.text(t.requestDetails));
    await shot('3-details-sheet');
    await tester.tap(find.byTooltip(t.increaseBags));
    await shot('4-after-plus');
    expect(backend.callsTo('PATCH /requests/20').length, 1);
    expect(tester.takeException(), isNull);
  });
}
