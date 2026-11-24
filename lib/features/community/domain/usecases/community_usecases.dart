import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/community_post.dart';
import '../repositories/community_repository.dart';

class CreatePost implements UseCase<CommunityPost, String> {
  CreatePost(this.repository);
  final CommunityRepository repository;
  @override
  Future<Either<Failure, CommunityPost>> call(String text) =>
      repository.createPost(text);
}

class UpdatePostParams {
  const UpdatePostParams(this.id, this.text);
  final int id;
  final String text;
}

class UpdatePost implements UseCase<CommunityPost, UpdatePostParams> {
  UpdatePost(this.repository);
  final CommunityRepository repository;
  @override
  Future<Either<Failure, CommunityPost>> call(UpdatePostParams p) =>
      repository.updatePost(p.id, p.text);
}

class ReactParams {
  const ReactParams(this.postId, this.reaction);
  final int postId;
  final PostReaction? reaction;
}

class ReactToPost implements UseCase<CommunityPost, ReactParams> {
  ReactToPost(this.repository);
  final CommunityRepository repository;
  @override
  Future<Either<Failure, CommunityPost>> call(ReactParams p) =>
      repository.react(p.postId, p.reaction);
}

class DeletePost implements UseCase<Unit, int> {
  DeletePost(this.repository);
  final CommunityRepository repository;
  @override
  Future<Either<Failure, Unit>> call(int id) => repository.deletePost(id);
}

class ReportParams {
  const ReportParams(this.target, this.id, this.reason);
  final ReportTarget target;
  final int id;
  final ReportReason reason;
}

class ReportContent implements UseCase<Unit, ReportParams> {
  ReportContent(this.repository);
  final CommunityRepository repository;
  @override
  Future<Either<Failure, Unit>> call(ReportParams p) =>
      repository.report(p.target, p.id, p.reason);
}
