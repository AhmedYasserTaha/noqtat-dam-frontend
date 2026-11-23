import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/usecases/blood_request_usecases.dart';

enum MyRequestsStatus { loading, ready, failure }

class MyRequestsState extends Equatable {
  const MyRequestsState({
    this.tab = RequestTab.active,
    this.status = MyRequestsStatus.loading,
    this.items = const [],
    this.failure,
    this.actionFailure,
  });
  final RequestTab tab;
  final MyRequestsStatus status;
  final List<BloodRequest> items;
  final Failure? failure, actionFailure;

  MyRequestsState copyWith({
    RequestTab? tab,
    MyRequestsStatus? status,
    List<BloodRequest>? items,
    Failure? failure,
    Failure? actionFailure,
  }) => MyRequestsState(
    tab: tab ?? this.tab,
    status: status ?? this.status,
    items: items ?? this.items,
    failure: failure,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [tab, status, items, failure, actionFailure];
}

class MyRequestsCubit extends Cubit<MyRequestsState> {
  MyRequestsCubit(this._mine, this._update) : super(const MyRequestsState());
  final GetMyRequests _mine;
  final UpdateMyRequest _update;

  Future<void> load([RequestTab? tab]) async {
    final next = tab ?? state.tab;
    emit(
      MyRequestsState(
        tab: next,
        status: MyRequestsStatus.loading,
        items: next == state.tab ? state.items : const [],
      ),
    );
    final result = await _mine(next);
    if (isClosed || state.tab != next) return;
    result.fold(
      (f) => emit(state.copyWith(status: MyRequestsStatus.failure, failure: f)),
      (items) =>
          emit(state.copyWith(status: MyRequestsStatus.ready, items: items)),
    );
  }

  /// Author sets how many bags were actually collected.
  Future<void> setBagsCollected(int id, int bags) =>
      _apply(UpdateRequestParams(id, bagsCollected: bags));

  Future<void> setStatus(int id, RequestStatus status) =>
      _apply(UpdateRequestParams(id, status: status));

  Future<void> _apply(UpdateRequestParams params) async {
    final result = await _update(params);
    if (isClosed) return;
    await result.fold(
      (f) async => emit(state.copyWith(actionFailure: f)),
      (_) => load(),
    );
  }
}
