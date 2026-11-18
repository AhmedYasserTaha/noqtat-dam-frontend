import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_page.dart';

enum FeedStatus { initial, loading, loaded, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.cursor,
    this.hasMore = true,
    this.loadingMore = false,
    this.failure,
  });
  final FeedStatus status;
  final List<Post> posts;
  final PostCursor? cursor;
  final bool hasMore, loadingMore;
  final Failure? failure;
  @override
  List<Object?> get props => [
    status,
    posts,
    cursor,
    hasMore,
    loadingMore,
    failure,
  ];
}
