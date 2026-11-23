import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/usecases/blood_request_usecases.dart';

enum CreateStatus { idle, submitting, success, failure }

class BloodRequestState extends Equatable {
  const BloodRequestState({this.status = CreateStatus.idle, this.failure});
  final CreateStatus status;
  final Failure? failure;
  @override
  List<Object?> get props => [status, failure];
}

/// Create-request flow (the review sheet confirms, then [submit] publishes).
class BloodRequestCubit extends Cubit<BloodRequestState> {
  BloodRequestCubit(this._create) : super(const BloodRequestState());
  final CreateBloodRequest _create;

  Future<void> submit(BloodRequestDraft draft) async {
    if (state.status == CreateStatus.submitting) return;
    emit(const BloodRequestState(status: CreateStatus.submitting));
    final result = await _create(draft);
    if (isClosed) return;
    result.fold(
      (f) => emit(BloodRequestState(status: CreateStatus.failure, failure: f)),
      (_) => emit(const BloodRequestState(status: CreateStatus.success)),
    );
  }
}
