import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';

sealed class PhoneEvent {
  const PhoneEvent();
}

class PhoneCodeSent extends PhoneEvent {
  const PhoneCodeSent(this.verificationId);
  final String verificationId;
}

class PhoneVerified extends PhoneEvent {
  const PhoneVerified();
}

abstract interface class AuthRepository {
  Stream<Either<Failure, AuthUser?>> watch();
  Stream<Either<Failure, PhoneEvent>> requestCode(String phone);
  Future<Either<Failure, Unit>> verify(String verificationId, String code);
  Future<Either<Failure, Unit>> signOut();
}
