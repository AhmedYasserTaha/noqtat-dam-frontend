import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post_page.dart';

abstract interface class FeedRepository {
  Stream<Either<Failure, PostPage>> watch({PostCursor? after, int limit = 20});
}
