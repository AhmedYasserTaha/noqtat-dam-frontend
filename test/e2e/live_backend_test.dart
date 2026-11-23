// Runs the real data layer against a running backend. Skipped unless
// E2E_API_URL is set, e.g.:
//   E2E_API_URL=http://127.0.0.1:3055 E2E_SMS_LOG=/tmp/server.log flutter test test/e2e
import 'dart:io';

import 'package:damy/core/network/api_client.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:damy/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:damy/features/auth/domain/entities/auth_user.dart';
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

class _Session {
  _Session(String url) {
    tokens = MemoryTokenStore();
    api = ApiClient(baseUrl: url, tokens: tokens);
    auth = AuthRepositoryImpl(AuthRemoteDataSource(api, tokens));
    profile = ProfileRepositoryImpl(ProfileRemoteDataSource(api, tokens));
    requests = BloodRequestRepositoryImpl(BloodRequestRemoteDataSource(api));
    feed = FeedRepositoryImpl(FeedRemoteDataSource(api));
  }
  late final MemoryTokenStore tokens;
  late final ApiClient api;
  late final AuthRepositoryImpl auth;
  late final ProfileRepositoryImpl profile;
  late final BloodRequestRepositoryImpl requests;
  late final FeedRepositoryImpl feed;
}

T ok<T>(dynamic either) =>
    either.getOrElse((Object? f) => throw StateError('$f')) as T;

void main() {
  final url = Platform.environment['E2E_API_URL'];
  final smsLog = Platform.environment['E2E_SMS_LOG'];
  setUpAll(() => HttpOverrides.global = null);

  test(
    'register, request, pledge, self-report, reset password',
    () async {
      final a = _Session(url!);
      final b = _Session(url);
      final stamp = DateTime.now().millisecondsSinceEpoch % 100000000;
      final phoneA = '0100${stamp.toString().padLeft(8, '0')}'.substring(0, 11);
      final phoneB = '0111${stamp.toString().padLeft(8, '0')}'.substring(0, 11);

      final userA = ok<AuthUser>(
        await a.auth.register(
          RegisterData(
            name: 'أحمد',
            phone: phoneA,
            password: 'password1',
            bloodType: 'O-',
            governorateId: 'EG01',
            districtId: 'EG0101',
          ),
        ),
      );
      expect(userA.bloodType, 'O-');
      ok<AuthUser>(
        await b.auth.register(
          RegisterData(
            name: 'منى',
            phone: phoneB,
            password: 'password1',
            bloodType: 'A+',
            governorateId: 'EG01',
            districtId: 'EG0101',
          ),
        ),
      );

      // duplicate phone and wrong password map to typed codes
      final dup = await a.auth.register(
        RegisterData(
          name: 'x',
          phone: phoneA,
          password: 'password1',
          bloodType: 'O-',
        ),
      );
      expect(dup.getLeft().toNullable()!.code, ApiErrorCodes.phoneTaken);
      final wrong = await _Session(url).auth.login(phoneA, 'nope-nope');
      expect(
        wrong.getLeft().toNullable()!.code,
        ApiErrorCodes.wrongCredentials,
      );

      // A publishes a request
      final created = ok<BloodRequest>(
        await a.requests.create(
          BloodRequestDraft(
            bloodType: 'B-',
            bagsNeeded: 2,
            hospitalName: 'مستشفى المنصورة',
            governorateId: 'EG01',
            districtId: 'EG0101',
            urgency: Urgency.critical,
            contactPhone: phoneA,
            notes: 'عاجل',
          ),
        ),
      );
      expect(created.isMine, isTrue);
      expect(created.district?.ar, isNotEmpty);

      // B sees it, exact blood-type filter does not match A+ ... and contact is hidden
      var feedB = ok<List<BloodRequest>>(await b.feed.feed(const FeedQuery()));
      final seen = feedB.firstWhere((r) => r.id == created.id);
      expect(seen.contactPhone, isNull);
      final myBlood = ok<List<BloodRequest>>(
        await b.feed.feed(const FeedQuery(filter: RequestFilter.myBlood)),
      );
      expect(myBlood.where((r) => r.id == created.id), isEmpty);
      final nearby = ok<List<BloodRequest>>(
        await b.feed.feed(const FeedQuery(filter: RequestFilter.nearby)),
      );
      expect(nearby.any((r) => r.id == created.id), isTrue);

      // B pledges, contact unlocks, donated is only a self-report
      final pledged = ok<BloodRequest>(await b.requests.pledge(created.id));
      expect(pledged.contactPhone, phoneA);
      final donated = ok<BloodRequest>(
        await b.requests.reportDonated(created.id),
      );
      expect(donated.myPledge, PledgeStatus.donated);
      expect(
        donated.bagsCollected,
        0,
        reason: 'a self-report must not change the count',
      );

      // Only A can change the bags; B is refused
      final denied = await b.requests.update(created.id, bagsCollected: 1);
      expect(denied.isLeft(), isTrue);
      final updated = ok<BloodRequest>(
        await a.requests.update(created.id, bagsCollected: 1),
      );
      expect(updated.bagsCollected, 1);
      final mine = ok<List<BloodRequest>>(
        await a.requests.mine(RequestTab.active),
      );
      expect(mine.any((r) => r.id == created.id), isTrue);
      final done = ok<BloodRequest>(
        await a.requests.update(created.id, status: RequestStatus.fulfilled),
      );
      expect(done.status, RequestStatus.fulfilled);
      final completed = ok<List<BloodRequest>>(
        await a.requests.mine(RequestTab.completed),
      );
      expect(completed.any((r) => r.id == created.id), isTrue);

      // profile + home
      final p = ok<UserProfile>(
        await a.profile.update(const ProfileUpdate(isAvailable: false)),
      );
      expect(p.isAvailable, isFalse);
      final home = ok<HomeData>(await a.feed.home());
      expect(home.readiness.isAvailable, isFalse);
      final history = ok<List<DonationRecord>>(await b.profile.donations());
      expect(history, hasLength(1));

      // forgot / reset (dev stub: the code is read from the server log)
      ok<dynamic>(await _Session(url).auth.requestPasswordReset(phoneA));
      final log = File(smsLog!).readAsStringSync();
      final code = RegExp(r'to ' + phoneA + r': .*?(\d{6})')
          .allMatches(log)
          .last
          .group(1)!;
      final badReset = await _Session(url).auth
          .resetPassword(phoneA, '000000', 'newpassword1');
      expect(badReset.getLeft().toNullable()!.code, ApiErrorCodes.invalidCode);
      ok<dynamic>(
        await _Session(url).auth.resetPassword(phoneA, code, 'newpassword1'),
      );
      ok<AuthUser>(await _Session(url).auth.login(phoneA, 'newpassword1'));

      // account deletion clears the token and the login stops working
      ok<dynamic>(await b.profile.deleteAccount());
      expect(await b.tokens.read(), isNull);
      expect(
        (await _Session(url).auth.login(phoneB, 'password1')).isLeft(),
        isTrue,
      );
    },
    skip: url == null || smsLog == null
        ? 'set E2E_API_URL and E2E_SMS_LOG'
        : false,
  );
}
