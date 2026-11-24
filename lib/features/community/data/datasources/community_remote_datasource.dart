import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/community_post.dart';
import '../models/community_post_model.dart';

class CommunityRemoteDataSource {
  CommunityRemoteDataSource(this.api);
  final ApiClient api;

  Future<CommunityPost> create(String text) async => communityPostFromJson(
    await api.post(ApiConstants.posts, body: {'text': text}),
  );

  Future<CommunityPost> react(int id, PostReaction? reaction) async =>
      communityPostFromJson(
        await api.put(
          ApiConstants.postReaction(id),
          body: {'reaction': reaction?.api},
        ),
      );

  Future<void> delete(int id) async {
    await api.delete(ApiConstants.post(id));
  }

  Future<void> report(ReportTarget target, int id, ReportReason reason) async {
    final path = target == ReportTarget.request
        ? ApiConstants.requestReport(id)
        : ApiConstants.postReport(id);
    await api.post(path, body: {'reason': reason.api});
  }
}
