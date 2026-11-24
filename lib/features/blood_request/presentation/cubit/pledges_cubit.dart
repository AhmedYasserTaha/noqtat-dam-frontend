import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/donor_pledge.dart';
import '../../domain/usecases/blood_request_usecases.dart';

class PledgesState extends Equatable {
  const PledgesState({
    this.loading = true,
    this.items = const [],
    this.failure,
  });
  final bool loading;
  final List<DonorPledge> items;
  final Failure? failure;
  @override
  List<Object?> get props => [loading, items, failure];
}

class PledgesCubit extends Cubit<PledgesState> {
  PledgesCubit(this._get) : super(const PledgesState());
  final GetRequestPledges _get;

  Future<void> load(int requestId) async {
    emit(const PledgesState());
    final r = await _get(requestId);
    if (isClosed) return;
    r.fold(
      (f) => emit(PledgesState(loading: false, failure: f)),
      (items) => emit(PledgesState(loading: false, items: items)),
    );
  }
}
