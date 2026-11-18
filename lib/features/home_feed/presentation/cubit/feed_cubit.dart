import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/watch_posts.dart';
import '../../domain/entities/post.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this.watchPosts) : super(const FeedState());
  final WatchPosts watchPosts;
  StreamSubscription<Object?>? _subscription;
  int _generation = 0;
  Future<void> load() async {
    final generation = ++_generation;
    emit(const FeedState(status: FeedStatus.loading));
    await _subscription?.cancel();
    if (isClosed || generation != _generation) return;
    _subscription = watchPosts().listen((result) {
      if (isClosed || generation != _generation) return;
      result.fold(
        (f) => emit(FeedState(status: FeedStatus.failure, failure: f)),
        (page) => emit(
          FeedState(
            status: FeedStatus.loaded,
            posts: page.posts,
            cursor: page.cursor,
            hasMore: page.hasMore,
          ),
        ),
      );
    });
  }

  Future<void> loadMore() async {
    if (state.status != FeedStatus.loaded ||
        state.loadingMore ||
        !state.hasMore ||
        state.cursor == null) {
      return;
    }
    final previous = state;
    final generation = _generation;
    emit(
      FeedState(
        status: FeedStatus.loaded,
        posts: previous.posts,
        cursor: previous.cursor,
        hasMore: previous.hasMore,
        loadingMore: true,
      ),
    );
    // Keep pagination boundaries stable. load() restores the live first page.
    await _subscription?.cancel();
    if (isClosed || generation != _generation) return;
    final result = await watchPosts(after: previous.cursor).first;
    if (isClosed || generation != _generation) return;
    result.fold(
      (f) => emit(
        FeedState(
          status: FeedStatus.loaded,
          posts: state.posts,
          cursor: previous.cursor,
          hasMore: previous.hasMore,
          failure: f,
        ),
      ),
      (page) {
        final posts = <String, Post>{
          for (final p in state.posts) p.id: p,
          for (final p in page.posts) p.id: p,
        }.values.toList();
        emit(
          FeedState(
            status: FeedStatus.loaded,
            posts: posts,
            cursor: page.cursor ?? previous.cursor,
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    ++_generation;
    await _subscription?.cancel();
    return super.close();
  }
}
