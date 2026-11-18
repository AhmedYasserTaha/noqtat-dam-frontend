import 'package:equatable/equatable.dart';

import 'post.dart';

class PostCursor extends Equatable {
  const PostCursor(this.createdAt, this.id);
  final DateTime createdAt;
  final String id;
  @override
  List<Object?> get props => [createdAt, id];
}

class PostPage extends Equatable {
  const PostPage(this.posts, {required this.hasMore, this.cursor});
  final List<Post> posts;
  final bool hasMore;
  final PostCursor? cursor;
  @override
  List<Object?> get props => [posts, hasMore, cursor];
}
