import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../blood_request/data/datasources/blood_request_remote_datasource.dart';
import '../../../blood_request/data/models/blood_request_model.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../../../community/data/models/community_post_model.dart';
import '../../domain/entities/home_data.dart';

class FeedRemoteDataSource {
  FeedRemoteDataSource(this.api);
  final ApiClient api;

  Future<HomeData> home() async {
    final j = await api.get(ApiConstants.home);
    final r = j['readiness'] as Json;
    final urgent = j['closestUrgentRequest'];
    return HomeData(
      readiness: Readiness(
        isAvailable: r['isAvailable'] as bool? ?? true,
        donationsCount: r['donationsCount'] as int? ?? 0,
        lastDonationAt: r['lastDonationAt'] == null
            ? null
            : DateTime.parse(r['lastDonationAt'] as String),
      ),
      closestUrgent: urgent == null
          ? null
          : BloodRequestModel.fromJson(urgent as Json),
      posts: [
        for (final p in j['posts'] as List<dynamic>)
          communityPostFromJson(p as Json),
      ],
      unreadNotifications: j['unreadNotifications'] as int? ?? 0,
    );
  }

  Future<PagedList<BloodRequest>> feed(FeedQuery q, {String? cursor}) async {
    final body = await api.get(
      ApiConstants.requests,
      query: {
        'filter': q.filter.api,
        'governorateId': q.governorateId,
        'districtId': q.districtId,
        'cursor': cursor,
      },
    );
    return PagedList(
      BloodRequestRemoteDataSource.parseList(body),
      body['nextCursor'] as String?,
    );
  }

  Future<PagedList<CommunityPost>> posts({String? before}) async {
    final body = await api.get(ApiConstants.posts, query: {'before': before});
    final next = body['nextBefore'];
    return PagedList([
      for (final p in body['items'] as List<dynamic>)
        communityPostFromJson(p as Json),
    ], next?.toString());
  }
}
