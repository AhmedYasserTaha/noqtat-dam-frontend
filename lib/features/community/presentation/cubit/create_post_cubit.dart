import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blood_request/presentation/cubit/blood_request_cubit.dart'
    show CreateStatus;
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/community_usecases.dart';

export '../../../blood_request/presentation/cubit/blood_request_cubit.dart'
    show CreateStatus;

class CreatePostState extends Equatable {
  const CreatePostState({this.status = CreateStatus.idle, this.failure});
  final CreateStatus status;
  final Failure? failure;
  @override
  List<Object?> get props => [status, failure];
}

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit(this._create) : super(const CreatePostState());
  final CreatePost _create;

  Future<void> submit(String text) async {
    if (state.status == CreateStatus.submitting) return;
    emit(const CreatePostState(status: CreateStatus.submitting));
    final result = await _create(text.trim());
    if (isClosed) return;
    result.fold(
      (f) => emit(CreatePostState(status: CreateStatus.failure, failure: f)),
      (_) => emit(const CreatePostState(status: CreateStatus.success)),
    );
  }
}
