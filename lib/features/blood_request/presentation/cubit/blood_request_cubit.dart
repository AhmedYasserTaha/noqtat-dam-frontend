import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/usecases/blood_request_usecases.dart';

enum CreateStatus { idle, submitting, success, failure }

class BloodRequestState extends Equatable {
  const BloodRequestState({
    this.status = CreateStatus.idle,
    this.failure,
    this.request,
  });
  final BloodRequest? request;
  final CreateStatus status;
  final Failure? failure;
  @override
  List<Object?> get props => [status, failure, request];
}

/// Create-request flow (the review sheet confirms, then [submit] publishes).
class BloodRequestCubit extends Cubit<BloodRequestState> {
  BloodRequestCubit(this._create, [this._update])
    : super(const BloodRequestState());
  final UpdateMyRequest? _update;
  final CreateBloodRequest _create;

  Future<void> submit(
    BloodRequestDraft draft, {
    int? requestId,
    BloodRequest? original,
  }) async {
    if (state.status == CreateStatus.submitting) return;
    emit(const BloodRequestState(status: CreateStatus.submitting));
    final result = requestId == null
        ? await _create(draft)
        : await _update!(
            UpdateRequestParams(requestId, draft: draft, original: original),
          );
    if (isClosed) return;
    result.fold(
      (f) => emit(BloodRequestState(status: CreateStatus.failure, failure: f)),
      (request) => emit(
        BloodRequestState(status: CreateStatus.success, request: request),
      ),
    );
  }
}
