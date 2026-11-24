import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this.remote);
  final FeedRemoteDataSource remote;

  @override
  Future<Either<Failure, HomeData>> home() => safeCall(remote.home);

  @override
  Future<Either<Failure, PagedList<BloodRequest>>> feed(
    FeedQuery query, {
    String? cursor,
  }) => safeCall(() => remote.feed(query, cursor: cursor));

  @override
  Future<Either<Failure, PagedList<CommunityPost>>> posts({String? before}) =>
      safeCall(() => remote.posts(before: before));
}
