import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthUser>> register(RegisterData data);
  Future<Either<Failure, AuthUser>> login(String phone, String password);

  /// Restores a saved session. `Right(null)` means no valid session.
  Future<Either<Failure, AuthUser?>> restore();
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, Unit>> requestPasswordReset(String phone);
  Future<Either<Failure, Unit>> resetPassword(
    String phone,
    String code,
    String newPassword,
  );

  /// Fires when the server says the saved session is no longer valid.
  Stream<void> get sessionExpired;
}
