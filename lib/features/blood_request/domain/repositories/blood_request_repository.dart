import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/blood_request.dart';

abstract interface class BloodRequestRepository {
  Future<Either<Failure, BloodRequest>> create(BloodRequestDraft draft);
  Future<Either<Failure, List<BloodRequest>>> mine(RequestTab tab);

  /// Author only. Updates the bags collected and/or closes the request.
  Future<Either<Failure, BloodRequest>> update(
    int id, {
    int? bagsCollected,
    RequestStatus? status,
  });
  Future<Either<Failure, BloodRequest>> pledge(int id);

  /// The donor's own statement that they donated. Not verified by anyone.
  Future<Either<Failure, BloodRequest>> reportDonated(int id);
  Future<Either<Failure, BloodRequest>> cancelPledge(int id);
}
