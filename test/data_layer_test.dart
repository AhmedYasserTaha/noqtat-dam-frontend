import 'package:damy/core/errors/failures.dart';
import 'package:damy/core/network/api_client.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/features/blood_request/data/datasources/blood_request_remote_datasource.dart';
import 'package:damy/features/blood_request/data/repositories_impl/blood_request_repository_impl.dart';
import 'package:damy/features/blood_request/domain/entities/blood_request.dart';
import 'package:damy/features/home_feed/data/datasources/feed_remote_datasource.dart';
import 'package:damy/features/home_feed/data/repositories_impl/feed_repository_impl.dart';
import 'package:damy/features/home_feed/domain/entities/home_data.dart';
import 'package:damy/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:damy/features/profile/data/repositories_impl/profile_repository_impl.dart';
import 'package:damy/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late MemoryTokenStore tokens;
  late ApiClient api;
  setUp(() {
    backend = FakeBackend();
    tokens = MemoryTokenStore('tok');
    api = backend.client(tokens);
  });

  group('blood requests', () {
    test(
      'create sends the API field names and omits empty optionals',
      () async {
        backend.on(
          'POST /requests',
          (_) => FakeReply(requestJson(id: 20), 201),
        );
        final repo = BloodRequestRepositoryImpl(
          BloodRequestRemoteDataSource(api),
        );
        final result = await repo.create(
          const BloodRequestDraft(
            bloodType: 'AB+',
            bagsNeeded: 4,
            hospitalName: 'مستشفى',
            governorateId: 'EG01',
            districtId: 'EG0101',
            urgency: Urgency.within24h,
            contactPhone: '01012345678',
          ),
        );
        expect(result.isRight(), isTrue);
        final body = backend.callsTo('POST /requests').single.body as Map;
        expect(body, {
          'bloodType': 'AB+',
          'bagsNeeded': 4,
          'hospitalName': 'مستشفى',
          'governorateId': 'EG01',
          'districtId': 'EG0101',
          'districtIds': ['EG0101'],
          'urgency': 'within_24h',
          'contactPhone': '01012345678',
        });
      },
    );

    test('maps server errors to typed failures', () async {
      final repo = BloodRequestRepositoryImpl(
        BloodRequestRemoteDataSource(api),
      );
      backend.on(
        'POST /requests/1/pledge',
        (_) => FakeReply({'error': 'already pledged'}, 409),
      );
      backend.on(
        'PATCH /requests/1',
        (_) => FakeReply({'error': 'forbidden'}, 403),
      );
      backend.on('GET /requests/mine', (_) => FakeReply({'error': 'x'}, 500));
      expect(
        (await repo.pledge(1)).getLeft().toNullable(),
        isA<ConflictFailure>(),
      );
      expect(
        (await repo.update(1, bagsCollected: 1)).getLeft().toNullable(),
        isA<PermissionFailure>(),
      );
      expect(
        (await repo.mine(RequestTab.active)).getLeft().toNullable(),
        isA<ServerFailure>(),
      );
      expect(
        (await repo.cancelPledge(404)).getLeft().toNullable(),
        isA<NotFoundFailure>(),
      );
    });

    test('update only sends the fields that changed', () async {
      backend.on('PATCH /requests/5', (_) => FakeReply(requestJson(id: 5)));
      final repo = BloodRequestRepositoryImpl(
        BloodRequestRemoteDataSource(api),
      );
      await repo.update(5, status: RequestStatus.fulfilled);
      await repo.update(5, bagsCollected: 2);
      final bodies = backend.callsTo('PATCH /requests/5').map((c) => c.body);
      expect(bodies, [
        {'status': 'fulfilled'},
        {'bagsCollected': 2},
      ]);
    });
  });

  group('feed', () {
    test(
      'filter and location go to the query string; null ids are dropped',
      () async {
        stubHome(backend);
        final repo = FeedRepositoryImpl(FeedRemoteDataSource(api));
        final feed = await repo.feed(
          const FeedQuery(filter: RequestFilter.myBlood),
        );
        expect(feed.isRight(), isTrue);
        final q = backend.callsTo('GET /requests').single.query;
        expect(q, {'filter': 'my_blood'});
      },
    );

    test('home parses readiness without inventing eligibility', () async {
      stubHome(backend);
      final home = (await FeedRepositoryImpl(
        FeedRemoteDataSource(api),
      ).home()).getOrElse((_) => throw StateError('failed'));
      expect(home.readiness.isAvailable, isTrue);
      expect(home.readiness.donationsCount, 0);
      expect(home.closestUrgent, isNull);
    });

    test(
      'the nearby 400 becomes a need-governorate validation failure',
      () async {
        backend.on(
          'GET /requests',
          (_) => FakeReply({
            'error': 'set your governorate in the profile first',
          }, 400),
        );
        final r = await FeedRepositoryImpl(FeedRemoteDataSource(api))
            .feed(const FeedQuery(filter: RequestFilter.nearby));
        final f = r.getLeft().toNullable();
        expect(f, isA<ValidationFailure>());
        expect(f!.code, ApiErrorCodes.needGovernorate);
      },
    );
  });

  group('profile and session', () {
    test('update sends only what changed', () async {
      backend.on('PATCH /profile', (_) => FakeReply(meJson(isAvailable: false)));
      final repo = ProfileRepositoryImpl(ProfileRemoteDataSource(api, tokens));
      final p = (await repo.update(const ProfileUpdate(isAvailable: false)))
          .getOrElse((_) => throw StateError('failed'));
      expect(p.isAvailable, isFalse);
      expect(backend.callsTo('PATCH /profile').single.body, {'isAvailable': false});
    });

    test('deleting the account clears the stored token', () async {
      backend.on('DELETE /profile', (_) => FakeReply({'ok': true}));
      final repo = ProfileRepositoryImpl(ProfileRemoteDataSource(api, tokens));
      expect((await repo.deleteAccount()).isRight(), isTrue);
      expect(await tokens.read(), isNull);
    });

    test('a failed delete keeps the token', () async {
      backend.on('DELETE /profile', (_) => FakeReply({'error': 'x'}, 500));
      final repo = ProfileRepositoryImpl(ProfileRemoteDataSource(api, tokens));
      expect((await repo.deleteAccount()).isLeft(), isTrue);
      expect(await tokens.read(), 'tok');
    });

    test(
      '401 on a request that carried a token signals session expiry',
      () async {
        backend.on('GET /profile', (_) => FakeReply({'error': 'unauthorized'}, 401));
        final expired = api.onUnauthorized.first;
        await ProfileRepositoryImpl(ProfileRemoteDataSource(api, tokens)).get();
        await expired.timeout(const Duration(seconds: 1));
      },
    );

    test('error strings map to stable codes', () {
      expect(
        ApiErrorCodes.fromMessage('invalid phone number'),
        ApiErrorCodes.invalidPhone,
      );
      expect(
        ApiErrorCodes.fromMessage('phone already registered'),
        ApiErrorCodes.phoneTaken,
      );
      expect(
        ApiErrorCodes.fromMessage('password must be at least 8 characters'),
        ApiErrorCodes.weakPassword,
      );
      expect(
        ApiErrorCodes.fromMessage('invalid or expired code'),
        ApiErrorCodes.invalidCode,
      );
      expect(
        ApiErrorCodes.fromMessage('something else'),
        ApiErrorCodes.invalid,
      );
    });
  });
}
