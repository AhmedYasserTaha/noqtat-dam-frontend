import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remote);
  final AuthRemoteDataSource remote;

  @override
  Stream<void> get sessionExpired => remote.sessionExpired;

  @override
  Future<Either<Failure, AuthUser>> register(RegisterData data) =>
      safeCall(() => remote.register(data));

  @override
  Future<Either<Failure, AuthUser>> login(String phone, String password) =>
      safeCall(() => remote.login(phone, password));

  @override
  Future<Either<Failure, AuthUser?>> restore() => safeCall(remote.restore);

  @override
  Future<Either<Failure, Unit>> logout() => safeCall(() async {
    await remote.logout();
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> requestPasswordReset(String phone) =>
      safeCall(() async {
        await remote.requestPasswordReset(phone);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> resetPassword(
    String phone,
    String code,
    String newPassword,
  ) => safeCall(() async {
    await remote.resetPassword(phone, code, newPassword);
    return unit;
  });
}
