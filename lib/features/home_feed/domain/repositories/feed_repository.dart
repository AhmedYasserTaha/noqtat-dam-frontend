import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../entities/home_data.dart';

abstract interface class FeedRepository {
  Future<Either<Failure, HomeData>> home();

  /// One page of open requests. Pass the previous page's `next` as [cursor].
  Future<Either<Failure, PagedList<BloodRequest>>> feed(
    FeedQuery query, {
    String? cursor,
  });

  /// One page of community posts, newest first. [before] is the previous
  /// page's `next`.
  Future<Either<Failure, PagedList<CommunityPost>>> posts({String? before});
}
