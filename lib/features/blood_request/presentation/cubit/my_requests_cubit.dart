import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/entities/donor_pledge.dart';
import '../../domain/usecases/blood_request_usecases.dart';

enum MyRequestsStatus { loading, ready, failure }

class MyRequestsState extends Equatable {
  const MyRequestsState({
    this.tab = RequestTab.all,
    this.hasRequests = false,
    this.status = MyRequestsStatus.loading,
    this.items = const [],
    this.failure,
    this.actionFailure,
  });
  final RequestTab tab;
  final bool hasRequests;
  final MyRequestsStatus status;
  final List<BloodRequest> items;
  final Failure? failure, actionFailure;

  MyRequestsState copyWith({
    RequestTab? tab,
    MyRequestsStatus? status,
    List<BloodRequest>? items,
    Failure? failure,
    Failure? actionFailure,
    bool? hasRequests,
  }) => MyRequestsState(
    tab: tab ?? this.tab,
    status: status ?? this.status,
    items: items ?? this.items,
    failure: failure,
    actionFailure: actionFailure,
    hasRequests: hasRequests ?? this.hasRequests,
  );

  @override
  List<Object?> get props => [
    tab,
    status,
    items,
    failure,
    actionFailure,
    hasRequests,
  ];
}

class MyRequestsCubit extends Cubit<MyRequestsState> {
  MyRequestsCubit(this._mine, this._update, this._confirm)
    : super(const MyRequestsState());
  final GetMyRequests _mine;
  final UpdateMyRequest _update;
  final ConfirmDonation _confirm;

  Future<void> load([RequestTab? tab]) async {
    final next = tab ?? state.tab;
    emit(
      MyRequestsState(
        tab: next,
        status: MyRequestsStatus.loading,
        items: next == state.tab ? state.items : const [],
        hasRequests: state.hasRequests,
      ),
    );
    final result = await _mine(next);
    if (isClosed || state.tab != next) return;
    result.fold(
      (f) => emit(state.copyWith(status: MyRequestsStatus.failure, failure: f)),
      (items) => emit(
        state.copyWith(
          status: MyRequestsStatus.ready,
          items: items,
          hasRequests: next == RequestTab.all
              ? items.isNotEmpty
              : state.hasRequests || items.isNotEmpty,
        ),
      ),
    );
  }

  /// Author sets how many bags were actually collected.
  Future<void> setBagsCollected(int id, int bags) =>
      _apply(UpdateRequestParams(id, bagsCollected: bags));

  /// Author confirms one donor really donated. The server adds one bag and
  /// never closes the request. Returns true when it went through.
  Future<bool> confirmDonation(int id, int donorId, CountMode mode) async {
    final result = await _confirm(ConfirmDonationParams(id, donorId, mode));
    if (isClosed) return false;
    return result.fold(
      (f) {
        emit(state.copyWith(actionFailure: f));
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }

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
