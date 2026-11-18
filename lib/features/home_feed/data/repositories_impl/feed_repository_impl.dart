import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/firebase_failure_mapper.dart';
import '../../domain/entities/post_page.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';
import '../models/post_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this.remote);
  final FeedRemoteDataSource remote;
  @override
  Stream<Either<Failure, PostPage>> watch({
    PostCursor? after,
    int limit = 20,
  }) async* {
    try {
      await for (final snapshot in remote.watch(after: after, limit: limit)) {
        final posts = snapshot.docs
            .map((doc) => PostModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
        yield Right(
          PostPage(
            posts,
            hasMore: posts.length == limit,
            cursor: posts.isEmpty
                ? null
                : PostCursor(posts.last.createdAt, posts.last.id),
          ),
        );
      }
    } catch (e) {
      yield Left(mapFailure(e));
    }
  }
}
