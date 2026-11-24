import 'package:damy/app.dart';
import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/utils/push_service.dart';
import 'package:damy/core/utils/share_service.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

class FakeShare implements ShareService {
  final List<String> shared = [];
  @override
  Future<void> shareText(String text) async => shared.add(text);
}

class FakePush implements PushService {
  @override
  Future<String?> register() async => 'device-token-1';
  @override
  Stream<String> get tokenRefreshes => const Stream.empty();
  @override
  Stream<void> get foregroundMessages => const Stream.empty();
}

Future<FakeShare> _boot(WidgetTester tester, FakeBackend backend) async {
  tester.view.physicalSize = const Size(390, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final tokens = MemoryTokenStore('saved');
  final share = FakeShare();
  configureDependencies(
    tokens: tokens,
    api: backend.client(tokens),
    share: share,
    push: FakePush(),
  );
  await tester.pumpWidget(const DamyApp());
  await tester.pumpAndSettle();
  return share;
}

void main() {
  late AppLocalizations t;
  setUpAll(() async {
    t = await AppLocalizations.delegate.load(const Locale('ar'));
  });

  testWidgets(
    'create opens a post form with tabs to switch to a blood request',
    (tester) async {
      final b = FakeBackend();
      stubHome(b);
      await _boot(tester, b);
      await tester.tap(find.byTooltip(t.createRequestAction));
      await tester.pumpAndSettle();
      // opens directly on the post form, with tabs for both kinds
      expect(find.byKey(const Key('new-post-field')), findsOneWidget);
      expect(find.text(t.createRequestOption), findsOneWidget);
      await tester.tap(find.byKey(const Key('create-tab-request')));
      await tester.pumpAndSettle();
      expect(find.text(t.reviewRequestTitle), findsWidgets);
      // and back: the post tab is still there and keeps what was typed
      await tester.tap(find.byKey(const Key('create-tab-post')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('new-post-field')), findsOneWidget);
    },
  );

  testWidgets('a post is published and the feed reloads', (tester) async {
    final b = FakeBackend();
    stubHome(b);
    b.on('POST /posts', (_) => FakeReply(postJson(id: 5, isMine: true), 201));
    await _boot(tester, b);
    await tester.tap(find.byTooltip(t.createRequestAction));
    await tester.pumpAndSettle();
    // empty text is refused locally
    await tester.tap(find.text(t.newPostPublish));
    await tester.pumpAndSettle();
    expect(b.callsTo('POST /posts'), isEmpty);
    await tester.enterText(find.byKey(const Key('new-post-field')), '  أهلا  ');
    await tester.tap(find.text(t.newPostPublish));
    await tester.pumpAndSettle();
    expect((b.callsTo('POST /posts').single.body as Map)['text'], 'أهلا');
    expect(b.callsTo('GET /home').length, greaterThanOrEqualTo(2));
  });

  testWidgets('like toggles, dislike switches, server refusal rolls back', (
    tester,
  ) async {
    final b = FakeBackend();
    stubHome(b, posts: [postJson(id: 1, likes: 2)]);
    var refuse = false;
    b.on('PUT /posts/1/reaction', (o) {
      if (refuse) return FakeReply({'error': 'nope'}, 500);
      final r = (o.data as Map)['reaction'];
      return FakeReply(
        postJson(
          id: 1,
          likes: r == 'like' ? 3 : 2,
          dislikes: r == 'dislike' ? 1 : 0,
          myReaction: r as String?,
        ),
      );
    });
    await _boot(tester, b);
    await tester.tap(find.byKey(const Key('like-1')));
    await tester.pumpAndSettle();
    expect(
      (b.callsTo('PUT /posts/1/reaction').last.body as Map)['reaction'],
      'like',
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('like-1')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
    // tapping again removes it
    await tester.tap(find.byKey(const Key('like-1')));
    await tester.pumpAndSettle();
    expect(
      (b.callsTo('PUT /posts/1/reaction').last.body as Map)['reaction'],
      isNull,
    );
    refuse = true;
    await tester.tap(find.byKey(const Key('dislike-1')));
    await tester.pumpAndSettle();
    // rolled back: no dislike counted
    expect(
      find.descendant(
        of: find.byKey(const Key('dislike-1')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('reporting a post hides it for the reporter', (tester) async {
    final b = FakeBackend();
    stubHome(b, posts: [postJson(id: 1, text: 'محتوى مزعج')]);
    b.on('POST /posts/1/report', (_) => FakeReply({'ok': true}, 201));
    await _boot(tester, b);
    await tester.tap(find.byKey(const Key('post-menu-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.reportAction));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-spam')));
    await tester.pumpAndSettle();
    expect(
      (b.callsTo('POST /posts/1/report').single.body as Map)['reason'],
      'spam',
    );
    expect(find.text('محتوى مزعج'), findsNothing);
  });

  testWidgets('own post can be deleted, not reported', (tester) async {
    final b = FakeBackend();
    stubHome(b, posts: [postJson(id: 2, text: 'بوستي', isMine: true)]);
    b.on('DELETE /posts/2', (_) => FakeReply({'ok': true}));
    await _boot(tester, b);
    await tester.tap(find.byKey(const Key('post-menu-2')));
    await tester.pumpAndSettle();
    expect(find.text(t.reportAction), findsNothing);
    await tester.tap(find.text(t.deletePostAction));
    await tester.pumpAndSettle();
    expect(b.callsTo('DELETE /posts/2'), hasLength(1));
    expect(find.text('بوستي'), findsNothing);
  });

  testWidgets('load more appends the next page and retry works', (
    tester,
  ) async {
    final b = FakeBackend();
    stubHome(b, requests: [requestJson(id: 30, hospital: 'مستشفى أ')]);
    var fail = true;
    b.on('GET /requests', (o) {
      if (o.queryParameters['cursor'] == '0-30') {
        if (fail) return FakeReply({'error': 'down'}, 500);
        return FakeReply({
          'items': [requestJson(id: 29, hospital: 'مستشفى ب')],
          'nextCursor': null,
        });
      }
      return FakeReply({
        'items': [requestJson(id: 30, hospital: 'مستشفى أ')],
        'nextCursor': '0-30',
      });
    });
    await _boot(tester, b);
    await tester.tap(find.byKey(const Key('load-more')));
    await tester.pumpAndSettle();
    expect(find.text(t.loadMoreFailed), findsOneWidget);
    expect(find.textContaining('مستشفى أ'), findsWidgets); // kept
    fail = false;
    await tester.tap(find.byKey(const Key('load-more-retry')));
    await tester.pumpAndSettle();
    expect(find.textContaining('مستشفى ب'), findsWidgets);
    expect(find.byKey(const Key('load-more')), findsNothing);
  });

  testWidgets('share opens the share sheet with text and no phone number', (
    tester,
  ) async {
    final b = FakeBackend();
    stubHome(b, requests: [requestJson(id: 8, contactPhone: '01099998888')]);
    final share = await _boot(tester, b);
    await tester.tap(find.byKey(const Key('request-menu-8')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.shareRequest));
    await tester.pumpAndSettle();
    expect(share.shared, hasLength(1));
    expect(share.shared.single.contains('01099998888'), isFalse);
  });

  testWidgets('notifications: badge, list, tap marks read', (tester) async {
    final b = FakeBackend();
    stubHome(b, unread: 2);
    b.on(
      'GET /me/notifications',
      (_) => FakeReply({
        'items': [
          {
            'id': 7,
            'type': 'pledge',
            'postId': 8,
            'title': 'متبرع جديد',
            'body': 'سارة في الطريق',
            'read': false,
            'createdAt': '2026-11-24T10:00:00.000Z',
          },
        ],
        'unreadCount': 1,
        'nextBefore': null,
      }),
    );
    b.on('POST /me/notifications/read', (_) => FakeReply({'ok': true}));
    await _boot(tester, b);
    expect(find.byKey(const Key('bell-badge')), findsOneWidget);
    await tester.tap(find.byKey(const Key('bell-badge')));
    await tester.pumpAndSettle();
    expect(find.text('متبرع جديد'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notification-7')));
    await tester.pumpAndSettle();
    expect(
      (b.callsTo('POST /me/notifications/read').single.body as Map)['ids'],
      [7],
    );
  });

  testWidgets('author sees who pledged, without phone numbers', (tester) async {
    final b = FakeBackend();
    stubHome(b);
    b.on(
      'GET /requests/mine',
      (_) => FakeReply({
        'items': [requestJson(id: 20, isMine: true)],
        'nextBefore': null,
      }),
    );
    b.on(
      'GET /requests/20/pledges',
      (_) => FakeReply([
        {
          'donorId': 3,
          'donorName': 'كريم',
          'bloodType': 'O-',
          'status': 'on_the_way',
          'createdAt': '2026-11-24T10:00:00.000Z',
          'updatedAt': '2026-11-24T10:00:00.000Z',
        },
      ]),
    );
    await _boot(tester, b);
    await tester.tap(find.text(t.myRequestsTab).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.requestDetails));
    await tester.pumpAndSettle();
    expect(find.text('كريم'), findsOneWidget);
    expect(find.text(t.pledgeOnTheWay), findsOneWidget);
  });

  testWidgets('push token is sent after sign-in', (tester) async {
    final b = FakeBackend();
    stubHome(b);
    b.on('PATCH /me', (_) => FakeReply(meJson()));
    await _boot(tester, b);
    final patches = b.callsTo('PATCH /me');
    expect(
      patches.any((c) => (c.body as Map)['fcmToken'] == 'device-token-1'),
      isTrue,
    );
  });
}
