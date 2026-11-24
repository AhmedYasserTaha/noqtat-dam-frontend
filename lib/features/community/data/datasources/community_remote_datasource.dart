import '../../../../core/network/api_client.dart';
import '../../domain/entities/community_post.dart';
import '../models/community_post_model.dart';

class CommunityRemoteDataSource {
  CommunityRemoteDataSource(this.api);
  final ApiClient api;

  Future<CommunityPost> create(String text) async =>
      communityPostFromJson(await api.post('/posts', body: {'text': text}));

  Future<CommunityPost> react(int id, PostReaction? reaction) async =>
      communityPostFromJson(
        await api.put('/posts/$id/reaction', body: {'reaction': reaction?.api}),
      );

  Future<void> delete(int id) async {
    await api.delete('/posts/$id');
  }

  Future<void> report(ReportTarget target, int id, ReportReason reason) async {
    final base = target == ReportTarget.request ? 'requests' : 'posts';
    await api.post('/$base/$id/report', body: {'reason': reason.api});
  }
}
