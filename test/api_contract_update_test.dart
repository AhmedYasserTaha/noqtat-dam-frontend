import 'package:damy/core/errors/failures.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:damy/features/profile/data/repositories_impl/profile_repository_impl.dart';
import 'package:damy/features/profile/domain/entities/user_profile.dart';
import 'package:damy/features/community/data/datasources/community_remote_datasource.dart';
import 'package:damy/features/community/data/repositories_impl/community_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late MemoryTokenStore tokens;
  late ProfileRepositoryImpl profile;
  late CommunityRepositoryImpl posts;
  setUp(() {
    backend = FakeBackend();
    tokens = MemoryTokenStore('saved');
    final api = backend.client(tokens);
    profile = ProfileRepositoryImpl(ProfileRemoteDataSource(api, tokens));
    posts = CommunityRepositoryImpl(CommunityRemoteDataSource(api));
  });

  test('profile read/update/donations/delete use the new routes', () async {
    backend.on('GET /profile', (_) => FakeReply(meJson()));
    backend.on('PATCH /profile', (_) => FakeReply(meJson()));
    backend.on('GET /profile/donations', (_) => FakeReply(<Object?>[]));
    backend.on('DELETE /profile', (_) => FakeReply({'ok': true}));
    expect((await profile.get()).isRight(), true);
    expect(
      (await profile.update(const ProfileUpdate(name: 'Updated'))).isRight(),
      true,
    );
    expect((await profile.donations()).isRight(), true);
    expect((await profile.deleteAccount()).isRight(), true);
    expect(backend.calls.map((c) => c.path), [
      '/profile',
      '/profile',
      '/profile/donations',
      '/profile',
    ]);
    expect(await tokens.read(), isNull);
  });

  test(
    'profile supports new self-reported fields and explicit date clearing',
    () async {
      backend.on('PATCH /profile', (_) => FakeReply(meJson()));
      final date = DateTime.parse('2026-11-24T12:00:00+02:00');
      await profile.update(
        ProfileUpdate(
          bloodType: 'AB-',
          lastDonationAt: date,
          donationsCount: 0,
          notificationsEnabled: false,
        ),
      );
      expect(backend.calls.last.body, {
        'bloodType': 'AB-',
        'lastDonationAt': '2026-11-24T10:00:00.000Z',
        'donationsCount': 0,
        'notificationsEnabled': false,
      });
      await profile.update(const ProfileUpdate(clearLastDonationAt: true));
      expect(backend.calls.last.body, {'lastDonationAt': null});
    },
  );

  test(
    'password change sends both passwords then clears the revoked session',
    () async {
      backend.on(
        'POST /profile/change-password',
        (_) => FakeReply({'ok': true}),
      );
      expect(
        (await profile.changePassword(
          'old-password',
          'new-password',
        )).isRight(),
        true,
      );
      final call = backend.calls.single;
      expect(call.body, {
        'currentPassword': 'old-password',
        'newPassword': 'new-password',
      });
      expect(call.headers['authorization'], 'Bearer saved');
      expect(await tokens.read(), isNull);
    },
  );

  test('failed password change preserves the session', () async {
    backend.on(
      'POST /profile/change-password',
      (_) => FakeReply({'error': 'wrong current password'}, 400),
    );
    expect(
      (await profile.changePassword('wrong', 'new-password')).isLeft(),
      true,
    );
    expect(await tokens.read(), 'saved');
  });

  test(
    'post editing only patches text and preserves server metadata',
    () async {
      final resultPost = postJson(
        id: 7,
        isMine: true,
        text: 'Updated text',
        likes: 9,
        dislikes: 2,
      );
      backend.on('PATCH /posts/7', (_) => FakeReply(resultPost));
      final result = (await posts.updatePost(
        7,
        'Updated text',
      )).getRight().toNullable()!;
      expect(backend.calls.single.body, {'text': 'Updated text'});
      expect(result.text, 'Updated text');
      expect(result.likes, 9);
      expect(result.dislikes, 2);
      expect(result.createdAt.toIso8601String(), resultPost['createdAt']);
    },
  );

  test('post edit rejection is a typed permission failure', () async {
    backend.on('PATCH /posts/7', (_) => FakeReply({'error': 'forbidden'}, 403));
    expect(
      (await posts.updatePost(7, 'Updated')).getLeft().toNullable(),
      isA<PermissionFailure>(),
    );
  });
}
