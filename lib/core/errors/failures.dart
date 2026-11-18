import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}

final class AuthFailure extends Failure {
  const AuthFailure(super.code);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.code);
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.code);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.code = 'unexpected']);
}
