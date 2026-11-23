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
  Future<Either<Failure, List<BloodRequest>>> feed(FeedQuery query) =>
      safeCall(() => remote.feed(query));
}
