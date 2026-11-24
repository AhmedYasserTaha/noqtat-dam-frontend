import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/community_post.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl(this.remote);
  final CommunityRemoteDataSource remote;

  @override
  Future<Either<Failure, CommunityPost>> createPost(String text) =>
      safeCall(() => remote.create(text));

  @override
  Future<Either<Failure, CommunityPost>> react(
    int postId,
    PostReaction? reaction,
  ) => safeCall(() => remote.react(postId, reaction));

  @override
  Future<Either<Failure, Unit>> deletePost(int postId) => safeCall(() async {
    await remote.delete(postId);
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> report(
    ReportTarget target,
    int id,
    ReportReason reason,
  ) => safeCall(() async {
    await remote.report(target, id, reason);
    return unit;
  });
}
