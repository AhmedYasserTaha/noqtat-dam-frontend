import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../../../blood_request/domain/usecases/blood_request_usecases.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/usecases/feed_usecases.dart';

enum FeedStatus { loading, ready, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.loading,
    this.query = const FeedQuery(),
    this.home,
    this.requests = const [],
    this.failure,
    this.actionFailure,
  });
  final FeedStatus status;
  final FeedQuery query;
  final HomeData? home;
  final List<BloodRequest> requests;
  final Failure? failure, actionFailure;

  FeedState copyWith({
    FeedStatus? status,
    FeedQuery? query,
    HomeData? home,
    List<BloodRequest>? requests,
    Failure? failure,
    Failure? actionFailure,
  }) => FeedState(
    status: status ?? this.status,
    query: query ?? this.query,
    home: home ?? this.home,
    requests: requests ?? this.requests,
    failure: failure,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    query,
    home,
    requests,
    failure,
    actionFailure,
  ];
}

class FeedCubit extends Cubit<FeedState> {
  FeedCubit(
    this._home,
    this._feed,
    this._pledge,
    this._reportDonated,
    this._cancelPledge,
  ) : super(const FeedState());
  final GetHome _home;
  final GetFeed _feed;
  final PledgeToDonate _pledge;
  final ReportDonated _reportDonated;
  final CancelPledge _cancelPledge;

  Future<void> load([FeedQuery? query]) async {
    final q = query ?? state.query;
    emit(state.copyWith(status: FeedStatus.loading, query: q));
    final results = await (_home(const NoParams()), _feed(q)).wait;
    if (isClosed || state.query != q) return;
    final home = results.$1;
    final feed = results.$2;
    final failure =
        home.fold((f) => f, (_) => null) ?? feed.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: FeedStatus.failure, failure: failure));
      return;
    }
    emit(
      state.copyWith(
        status: FeedStatus.ready,
        home: home.getOrElse((_) => throw StateError('unreachable')),
        requests: feed.getOrElse((_) => throw StateError('unreachable')),
      ),
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
    final result = await call();
    if (isClosed) return null;
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
}
