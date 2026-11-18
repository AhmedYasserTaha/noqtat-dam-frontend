import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/blood_request_draft.dart';
import '../../domain/usecases/blood_request_usecases.dart';
import 'blood_request_state.dart';

class BloodRequestCubit extends Cubit<BloodRequestState> {
  BloodRequestCubit(this.createRequest, this.pledgeToDonate)
    : super(const BloodRequestState());
  final CreateBloodRequest createRequest;
  final PledgeToDonate pledgeToDonate;
  Future<void> create(BloodRequestDraft draft) async {
    emit(const BloodRequestState(status: BloodRequestStatus.loading));
    final result = await createRequest(draft);
    if (isClosed) return;
    result.fold(
      (f) => emit(
        BloodRequestState(status: BloodRequestStatus.failure, failure: f),
      ),
      (id) => emit(
        BloodRequestState(status: BloodRequestStatus.success, postId: id),
      ),
    );
  }

  Future<void> pledge(String id) async {
    emit(const BloodRequestState(status: BloodRequestStatus.loading));
    final result = await pledgeToDonate(id);
    if (isClosed) return;
    result.fold(
      (f) => emit(
        BloodRequestState(status: BloodRequestStatus.failure, failure: f),
      ),
      (_) => emit(
        BloodRequestState(status: BloodRequestStatus.success, postId: id),
      ),
    );
  }
}
