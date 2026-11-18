import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  initial,
  loading,
  codeSent,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.verificationId,
    this.failure,
  });
  final AuthStatus status;
  final AuthUser? user;
  final String? verificationId;
  final Failure? failure;
  @override
  List<Object?> get props => [status, user, verificationId, failure];
}
