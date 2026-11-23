import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.remote);
  final ProfileRemoteDataSource remote;

  @override
  Future<Either<Failure, UserProfile>> get() => safeCall(remote.get);

  @override
  Future<Either<Failure, UserProfile>> update(ProfileUpdate update) =>
      safeCall(() => remote.update(update));

  @override
  Future<Either<Failure, List<DonationRecord>>> donations() =>
      safeCall(remote.donations);

  @override
  Future<Either<Failure, Unit>> deleteAccount() => safeCall(() async {
    await remote.deleteAccount();
    return unit;
  });
}
