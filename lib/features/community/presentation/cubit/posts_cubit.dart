import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../home_feed/domain/usecases/feed_usecases.dart';
import '../../domain/entities/community_post.dart';

class PostsState {
  const PostsState({
    this.items = const [],
    this.loading = false,
    this.next,
    this.failure,
  });
  final List<CommunityPost> items;
  final bool loading;
  final String? next;
  final Failure? failure;
}

class PostsCubit extends Cubit<PostsState> {
  PostsCubit(this._get) : super(const PostsState());
  final GetPosts _get;
  int _generation = 0;

  Future<void> load({bool more = false}) async {
    if (more && (state.loading || state.next == null)) return;
    final generation = more ? _generation : ++_generation;
    final previous = more ? state.items : <CommunityPost>[];
    final cursor = more ? state.next : null;
    emit(PostsState(items: previous, loading: true, next: cursor));
    final result = await _get(cursor);
    if (isClosed || generation != _generation) return;
    result.fold(
      (f) => emit(PostsState(items: previous, next: cursor, failure: f)),
      (page) => emit(
        PostsState(
          items: {
            for (final p in [...previous, ...page.items]) p.id: p,
          }.values.toList(),
          next: page.next,
        ),
      ),
    );
  }
}
