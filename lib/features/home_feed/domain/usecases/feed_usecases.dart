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

class GetFeed implements UseCase<List<BloodRequest>, FeedQuery> {
  GetFeed(this.repository);
  final FeedRepository repository;
  @override
  Future<Either<Failure, List<BloodRequest>>> call(FeedQuery q) =>
      repository.feed(q);
}
