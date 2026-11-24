import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, UserProfile>> get();
  Future<Either<Failure, UserProfile>> update(ProfileUpdate update);
  Future<Either<Failure, List<DonationRecord>>> donations();

  /// Deletes the account on the server and clears the local session.
  Future<Either<Failure, Unit>> deleteAccount();
  Future<Either<Failure, Unit>> changePassword(
    String currentPassword,
    String newPassword,
  );
}
