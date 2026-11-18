import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/firebase_failure_mapper.dart';
import '../../domain/entities/blood_request_draft.dart';
import '../../domain/repositories/blood_request_repository.dart';
import '../datasources/blood_request_remote_datasource.dart';

class BloodRequestRepositoryImpl implements BloodRequestRepository {
  BloodRequestRepositoryImpl(this.remote);
  final BloodRequestRemoteDataSource remote;
  @override
  Future<Either<Failure, String>> create(BloodRequestDraft d) async {
    try {
      return Right(
        await remote.create({
          'type': 'blood_request',
          'text': '',
          'bloodType': d.bloodType,
          'bagsNeeded': d.bagsNeeded,
          'bagsCollected': 0,
          'hospitalName': d.hospitalName,
          'governorate': d.governorate,
          'city': d.city,
          'urgency': d.urgency,
          'deadline': Timestamp.fromDate(d.deadline),
          'notes': d.notes,
          'status': 'open',
          'isVerified': false,
          'likesCount': 0,
          'commentsCount': 0,
        }, d.contactPhone),
      );
    } catch (e) {
      return Left(mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> pledge(String id) async {
    try {
      await remote.pledge(id);
      return const Right(unit);
    } catch (e) {
      return Left(mapFailure(e));
    }
  }
}
