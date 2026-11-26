import 'package:equatable/equatable.dart';

/// Domain-level failure. [code] is a stable machine code (never user text);
/// the presentation layer turns it into localized copy.
sealed class Failure extends Equatable {
  const Failure(this.code, {this.message});
  final String code;
  final String? message;
  @override
  List<Object?> get props => [code, message];
}

/// Wrong credentials, missing or expired session (HTTP 401).
final class AuthFailure extends Failure {
  const AuthFailure(super.code, {super.message});
}

/// The server rejected the input (HTTP 400). [code] is one of the
/// `ApiErrorCodes` values, or `invalid` when unknown.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.code, {super.message});
}

/// Already exists / state conflict (HTTP 409).
final class ConflictFailure extends Failure {
  const ConflictFailure(super.code, {super.message});
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.code, {super.message});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.code = 'not_found']);
  const NotFoundFailure.response(String code, String? message)
    : super(code, message: message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.code = 'network']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.code = 'server']);
  const ServerFailure.response(String code, String? message)
    : super(code, message: message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.code = 'unexpected']);
}
