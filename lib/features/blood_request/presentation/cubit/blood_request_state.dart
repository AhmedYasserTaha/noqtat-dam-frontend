import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';

enum BloodRequestStatus { initial, loading, success, failure }

class BloodRequestState extends Equatable {
  const BloodRequestState({
    this.status = BloodRequestStatus.initial,
    this.postId,
    this.failure,
  });
  final BloodRequestStatus status;
  final String? postId;
  final Failure? failure;
  @override
  List<Object?> get props => [status, postId, failure];
}
