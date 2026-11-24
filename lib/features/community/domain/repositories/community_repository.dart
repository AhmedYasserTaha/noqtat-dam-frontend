import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/community_post.dart';

abstract interface class CommunityRepository {
  Future<Either<Failure, CommunityPost>> createPost(String text);
  Future<Either<Failure, CommunityPost>> updatePost(int id, String text);

  /// [reaction] null removes the user's reaction.
  Future<Either<Failure, CommunityPost>> react(
    int postId,
    PostReaction? reaction,
  );
  Future<Either<Failure, Unit>> deletePost(int postId);
  Future<Either<Failure, Unit>> report(
    ReportTarget target,
    int id,
    ReportReason reason,
  );
}
