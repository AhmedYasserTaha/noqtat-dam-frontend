import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post_page.dart';
import '../repositories/feed_repository.dart';

class WatchPosts {
  WatchPosts(this.repository);
  final FeedRepository repository;
  Stream<Either<Failure, PostPage>> call({PostCursor? after}) =>
      repository.watch(after: after);
}
