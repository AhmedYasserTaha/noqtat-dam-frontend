import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../entities/home_data.dart';
import '../repositories/feed_repository.dart';

class GetHome implements UseCase<HomeData, NoParams> {
  GetHome(this.repository);
  final FeedRepository repository;
  @override
  Future<Either<Failure, HomeData>> call(NoParams p) => repository.home();
}

class GetFeed implements UseCase<PagedList<BloodRequest>, FeedPageParams> {
  GetFeed(this.repository);
  final FeedRepository repository;
  @override
  Future<Either<Failure, PagedList<BloodRequest>>> call(FeedPageParams p) =>
      repository.feed(p.query, cursor: p.cursor);
}

class GetPosts implements UseCase<PagedList<CommunityPost>, String?> {
  GetPosts(this.repository);
  final FeedRepository repository;
  @override
  Future<Either<Failure, PagedList<CommunityPost>>> call(String? before) =>
      repository.posts(before: before);
}
