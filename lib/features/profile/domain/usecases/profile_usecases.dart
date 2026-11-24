import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile implements UseCase<UserProfile, NoParams> {
  GetProfile(this.repository);
  final ProfileRepository repository;
  @override
  Future<Either<Failure, UserProfile>> call(NoParams p) => repository.get();
}

class UpdateProfile implements UseCase<UserProfile, ProfileUpdate> {
  UpdateProfile(this.repository);
  final ProfileRepository repository;
  @override
  Future<Either<Failure, UserProfile>> call(ProfileUpdate u) =>
      repository.update(u);
}

class GetDonationHistory implements UseCase<List<DonationRecord>, NoParams> {
  GetDonationHistory(this.repository);
  final ProfileRepository repository;
  @override
  Future<Either<Failure, List<DonationRecord>>> call(NoParams p) =>
      repository.donations();
}

class DeleteAccount implements UseCase<Unit, NoParams> {
  DeleteAccount(this.repository);
  final ProfileRepository repository;
  @override
  Future<Either<Failure, Unit>> call(NoParams p) => repository.deleteAccount();
}

class ChangePasswordParams {
  const ChangePasswordParams(this.currentPassword, this.newPassword);
  final String currentPassword, newPassword;
}

/// The caller should return to login after a successful password change.
class ChangePassword implements UseCase<Unit, ChangePasswordParams> {
  ChangePassword(this.repository);
  final ProfileRepository repository;
  @override
  Future<Either<Failure, Unit>> call(ChangePasswordParams p) =>
      repository.changePassword(p.currentPassword, p.newPassword);
}
