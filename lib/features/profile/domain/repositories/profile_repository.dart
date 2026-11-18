import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Stream<Either<Failure, UserProfile?>> watch(String uid);
  Future<Either<Failure, Unit>> save(UserProfile profile);
}
