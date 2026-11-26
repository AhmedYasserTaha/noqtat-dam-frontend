import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../../../blood_request/domain/usecases/blood_request_usecases.dart';
import '../../../community/domain/usecases/community_usecases.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/usecases/feed_usecases.dart';

enum FeedStatus { loading, ready, failure }

/// `home` returns this many posts; a full page means there may be more.
const homePostsPageSize = 10;

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.loading,
    this.query = const FeedQuery(),
    this.home,
    this.requests = const [],
    this.posts = const [],
    this.requestsNext,
    this.postsNext,
    this.loadingMore = false,
    this.loadMoreFailure,
    this.failure,
    this.actionFailure,
  });
  final FeedStatus status;
  final FeedQuery query;
  final HomeData? home;
  final List<BloodRequest> requests;
  final List<CommunityPost> posts;

  /// Cursors for the next page of each list (null = nothing more to load).
  final String? requestsNext, postsNext;
  final bool loadingMore;

  /// The last "load more" failed; the list keeps what it has and the user can
  /// retry.
  final Failure? loadMoreFailure;
  final Failure? failure, actionFailure;

  bool get hasMore => requestsNext != null || postsNext != null;

  FeedState copyWith({
    FeedStatus? status,
    FeedQuery? query,
    HomeData? home,
    List<BloodRequest>? requests,
    List<CommunityPost>? posts,
    String? requestsNext,
    String? postsNext,
    bool clearRequestsNext = false,
    bool clearPostsNext = false,
    bool? loadingMore,
    Failure? loadMoreFailure,
    Failure? failure,
    Failure? actionFailure,
  }) => FeedState(
    status: status ?? this.status,
    query: query ?? this.query,
    home: home ?? this.home,
    requests: requests ?? this.requests,
    posts: posts ?? this.posts,
    requestsNext: clearRequestsNext
        ? null
        : (requestsNext ?? this.requestsNext),
    postsNext: clearPostsNext ? null : (postsNext ?? this.postsNext),
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreFailure: loadMoreFailure,
    failure: failure,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    query,
    home,
    requests,
    posts,
    requestsNext,
    postsNext,
    loadingMore,
    loadMoreFailure,
    failure,
    actionFailure,
  ];
}

class FeedCubit extends Cubit<FeedState> {
  FeedCubit(
    this._home,
    this._feed,
    this._posts,
    this._pledge,
    this._reportDonated,
    this._cancelPledge,
    this._react,
    this._deletePost,
    this._report,
  ) : super(const FeedState());
  final GetHome _home;
  final GetFeed _feed;
  final GetPosts _posts;
  final PledgeToDonate _pledge;
  final ReportDonated _reportDonated;
  final CancelPledge _cancelPledge;
  final ReactToPost _react;
  final DeletePost _deletePost;
  final ReportContent _report;

  Future<void> load([FeedQuery? query]) async {
    final session = _session;
    final q = query ?? state.query;
    emit(state.copyWith(status: FeedStatus.loading, query: q));
    final results = await (
      _home(const NoParams()),
      _feed(FeedPageParams(q)),
    ).wait;
    if (isClosed || session != _session || state.query != q) return;
    final home = results.$1;
    final feed = results.$2;
    final failure =
        home.fold((f) => f, (_) => null) ?? feed.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: FeedStatus.failure, failure: failure));
      return;
    }
    final homeData = home.getOrElse((_) => throw StateError('unreachable'));
    final page = feed.getOrElse((_) => throw StateError('unreachable'));
    final posts = homeData.posts;
    emit(
      FeedState(
        status: FeedStatus.ready,
        query: q,
        home: homeData,
        requests: page.items,
        posts: q.filter == RequestFilter.all ? posts : const [],
        requestsNext: page.next,
        postsNext:
            q.filter == RequestFilter.all && posts.length >= homePostsPageSize
            ? posts.last.id.toString()
            : null,
      ),
    );
  }

  /// Loads the next page: requests first, then (on the "all" filter) posts.
  /// A failure keeps the current items and sets [FeedState.loadMoreFailure];
  /// calling this again retries.
  Future<void> loadMore() async {
    final session = _session;
    if (state.status != FeedStatus.ready ||
        state.loadingMore ||
        !state.hasMore) {
      return;
    }
    final q = state.query;
    emit(state.copyWith(loadingMore: true));
    if (state.requestsNext != null) {
      final result = await _feed(FeedPageParams(q, cursor: state.requestsNext));
      if (isClosed || session != _session || state.query != q) return;
      result.fold(
        (f) => emit(state.copyWith(loadingMore: false, loadMoreFailure: f)),
        (page) {
          final seen = {for (final r in state.requests) r.id};
          emit(
            state.copyWith(
              loadingMore: false,
              requests: [
                ...state.requests,
                ...page.items.where((r) => !seen.contains(r.id)),
              ],
              requestsNext: page.next,
              clearRequestsNext: page.next == null,
            ),
          );
        },
      );
      return;
    }
    final result = await _posts(state.postsNext);
    if (isClosed || session != _session || state.query != q) return;
    result.fold(
      (f) => emit(state.copyWith(loadingMore: false, loadMoreFailure: f)),
      (page) {
        final seen = {for (final p in state.posts) p.id};
        emit(
          state.copyWith(
            loadingMore: false,
            posts: [
              ...state.posts,
              ...page.items.where((p) => !seen.contains(p.id)),
            ],
            postsNext: page.next,
            clearPostsNext: page.next == null,
          ),
        );
      },
    );
  }

  /// Returns the updated request (with the unlocked contact phone), or null
  /// when the server refused; the reason is in [FeedState.actionFailure].
  Future<BloodRequest?> pledge(int id) => _act(() => _pledge(id));
  Future<BloodRequest?> reportDonated(int id) => _act(() => _reportDonated(id));
  Future<BloodRequest?> cancelPledge(int id) => _act(() => _cancelPledge(id));

  Future<BloodRequest?> _act(
    Future<Either<Failure, BloodRequest>> Function() call,
  ) async {
    final session = _session;
    final result = await call();
    if (isClosed || session != _session) return null;
    return result.fold(
      (f) {
        emit(state.copyWith(actionFailure: f));
        return null;
      },
      (updated) {
        // Refresh the lists in the background; the caller already has the
        // updated request.
        load();
        return updated;
      },
    );
  }

  /// Like / dislike. Tapping the reaction you already have removes it. The UI
  /// updates at once and goes back to the old value if the server refuses.
  Future<void> react(int postId, PostReaction tapped) async {
    final session = _session;
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    final before = state.posts[index];
    final next = before.myReaction == tapped ? null : tapped;
    _replacePost(before.withReaction(next));
    final result = await _react(ReactParams(postId, next));
    if (isClosed || session != _session) return;
    result.fold((f) {
      _replacePost(before);
      emit(state.copyWith(actionFailure: f));
    }, _replacePost);
  }

  void _replacePost(CommunityPost post) => emit(
    state.copyWith(
      posts: [for (final p in state.posts) p.id == post.id ? post : p],
    ),
  );

  Future<bool> deletePost(int postId) async {
    final session = _session;
    final result = await _deletePost(postId);
    if (isClosed || session != _session) return false;
    return result.fold(
      (f) {
        emit(state.copyWith(actionFailure: f));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            posts: state.posts.where((p) => p.id != postId).toList(),
          ),
        );
        return true;
      },
    );
  }

  /// Reports a request or post. The reporter stops seeing it right away.
  /// Reports are reviewed by hand by the app owner; nothing is hidden from
  /// other users automatically.
  Future<bool> report(ReportTarget target, int id, ReportReason reason) async {
    final session = _session;
    final result = await _report(ReportParams(target, id, reason));
    if (isClosed || session != _session) return false;
    return result.fold(
      (f) {
        emit(state.copyWith(actionFailure: f));
        return false;
      },
      (_) {
        // The featured urgent card is not in the list: reload so it goes too.
        if (target == ReportTarget.request) load();
        emit(
          state.copyWith(
            requests: target == ReportTarget.request
                ? state.requests.where((r) => r.id != id).toList()
                : null,
            posts: target == ReportTarget.post
                ? state.posts.where((p) => p.id != id).toList()
                : null,
          ),
        );
        return true;
      },
    );
  }

  int _session = 0;
  void reset() {
    _session++;
    emit(const FeedState());
  }
}
