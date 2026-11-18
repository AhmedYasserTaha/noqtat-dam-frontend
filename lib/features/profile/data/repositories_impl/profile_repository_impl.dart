import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/firebase_failure_mapper.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.remote);
  final ProfileRemoteDataSource remote;
  @override
  Stream<Either<Failure, UserProfile?>> watch(String uid) async* {
    try {
      await for (final doc in remote.watch(uid)) {
        yield Right(
          doc.exists
              ? UserProfileModel.fromMap({...doc.data()!, 'uid': doc.id})
              : null,
        );
      }
    } catch (e) {
      yield Left(mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> save(UserProfile p) async {
    try {
      final model = UserProfileModel(
        uid: p.uid,
        name: p.name,
        phone: p.phone,
        bloodType: p.bloodType,
        governorate: p.governorate,
        city: p.city,
        isAvailable: p.isAvailable,
        lastDonationAt: p.lastDonationAt,
        donationsCount: p.donationsCount,
        fcmToken: p.fcmToken,
        createdAt: p.createdAt,
      );
      final data = model.toMap()..remove('uid');
      await remote.save(p.uid, data);
      return const Right(unit);
    } catch (e) {
      return Left(mapFailure(e));
    }
  }
}
