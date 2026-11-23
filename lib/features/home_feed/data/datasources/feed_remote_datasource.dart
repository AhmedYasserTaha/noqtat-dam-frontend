import '../../../../core/network/api_client.dart';
import '../../../blood_request/data/datasources/blood_request_remote_datasource.dart';
import '../../../blood_request/data/models/blood_request_model.dart';
import '../../domain/entities/home_data.dart';

class FeedRemoteDataSource {
  FeedRemoteDataSource(this.api);
  final ApiClient api;

  Future<HomeData> home() async {
    final j = await api.get('/home');
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
          CommunityPost(
            id: (p as Json)['id'] as int,
            authorName: p['authorName'] as String? ?? '',
            text: p['text'] as String? ?? '',
            createdAt: DateTime.parse(p['createdAt'] as String),
          ),
      ],
    );
  }

  Future<List<BloodRequestModel>> feed(FeedQuery q) async =>
      BloodRequestRemoteDataSource.parseList(
        await api.get(
          '/requests',
          query: {
            'filter': q.filter.api,
            'governorateId': q.governorateId,
            'districtId': q.districtId,
          },
        ),
      );
}
