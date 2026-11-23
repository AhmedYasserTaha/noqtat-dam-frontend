import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser implements UseCase<AuthUser, RegisterData> {
  RegisterUser(this.repository);
  final AuthRepository repository;
  @override
  Future<Either<Failure, AuthUser>> call(RegisterData data) =>
      repository.register(data);
}

class LoginParams {
  const LoginParams(this.phone, this.password);
  final String phone, password;
}

class LoginUser implements UseCase<AuthUser, LoginParams> {
  LoginUser(this.repository);
  final AuthRepository repository;
  @override
  Future<Either<Failure, AuthUser>> call(LoginParams p) =>
      repository.login(p.phone, p.password);
}

class RestoreSession implements UseCase<AuthUser?, NoParams> {
  RestoreSession(this.repository);
  final AuthRepository repository;
  @override
  Future<Either<Failure, AuthUser?>> call(NoParams p) => repository.restore();
}

class SignOut implements UseCase<Unit, NoParams> {
  SignOut(this.repository);
  final AuthRepository repository;
  @override
  Future<Either<Failure, Unit>> call(NoParams p) => repository.logout();
}

class RequestPasswordReset implements UseCase<Unit, String> {
  RequestPasswordReset(this.repository);
  final AuthRepository repository;
  @override
  Future<Either<Failure, Unit>> call(String phone) =>
      repository.requestPasswordReset(phone);
}

class ResetPasswordParams {
  const ResetPasswordParams(this.phone, this.code, this.newPassword);
  final String phone, code, newPassword;
}

class ResetPassword implements UseCase<Unit, ResetPasswordParams> {
  ResetPassword(this.repository);
  final AuthRepository repository;
  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams p) =>
      repository.resetPassword(p.phone, p.code, p.newPassword);
}
