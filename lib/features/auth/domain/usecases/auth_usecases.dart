import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuth {
  WatchAuth(this.repository);
  final AuthRepository repository;
  Stream<Either<Failure, AuthUser?>> call() => repository.watch();
}

class RequestPhoneCode {
  RequestPhoneCode(this.repository);
  final AuthRepository repository;
  Stream<Either<Failure, PhoneEvent>> call(String phone) =>
      repository.requestCode(phone);
}

class VerifyCodeParams {
  const VerifyCodeParams(this.verificationId, this.code);
  final String verificationId, code;
}

class VerifyCode implements UseCase<Unit, VerifyCodeParams> {
  VerifyCode(this.repository);
  final AuthRepository repository;
  @override
  Future<Either<Failure, Unit>> call(VerifyCodeParams p) =>
      repository.verify(p.verificationId, p.code);
}

class SignOut implements UseCase<Unit, NoParams> {
  SignOut(this.repository);
  final AuthRepository repository;
  @override
  Future<Either<Failure, Unit>> call(NoParams p) => repository.signOut();
}
