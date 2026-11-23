import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
  resetCodeRequested,
  resetDone,
}

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.user, this.failure});
  final AuthStatus status;
  final AuthUser? user;
  final Failure? failure;
  bool get isLoading => status == AuthStatus.loading;
  @override
  List<Object?> get props => [status, user, failure];
}
