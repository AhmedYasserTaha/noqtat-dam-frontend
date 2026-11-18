import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class WatchProfile {
  WatchProfile(this.repository);
  final ProfileRepository repository;
  Stream<Either<Failure, UserProfile?>> call(String uid) =>
      repository.watch(uid);
}

class SaveProfile implements UseCase<Unit, UserProfile> {
  SaveProfile(this.repository);
  final ProfileRepository repository;
  @override
  Future<Either<Failure, Unit>> call(UserProfile profile) =>
      repository.save(profile);
}
