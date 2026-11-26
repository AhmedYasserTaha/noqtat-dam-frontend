import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/entities/donor_pledge.dart';
import '../../domain/repositories/blood_request_repository.dart';
import '../datasources/blood_request_remote_datasource.dart';

class BloodRequestRepositoryImpl implements BloodRequestRepository {
  BloodRequestRepositoryImpl(this.remote);
  final BloodRequestRemoteDataSource remote;

  @override
  Future<Either<Failure, BloodRequest>> create(BloodRequestDraft draft) =>
      safeCall(() => remote.create(draft));

  @override
  Future<Either<Failure, List<BloodRequest>>> mine(RequestTab tab) =>
      safeCall(() => remote.mine(tab));

  @override
  Future<Either<Failure, BloodRequest>> update(
    int id, {
    int? bagsCollected,
    RequestStatus? status,
    BloodRequestDraft? draft,
    BloodRequest? original,
  }) => safeCall(
    () => remote.update(
      id,
      bagsCollected: bagsCollected,
      status: status,
      draft: draft,
      original: original,
    ),
  );

  @override
  Future<Either<Failure, List<DonorPledge>>> pledges(int requestId) =>
      safeCall(() => remote.pledges(requestId));

  @override
  Future<Either<Failure, BloodRequest>> pledge(int id) =>
      safeCall(() => remote.pledge(id));

  @override
  Future<Either<Failure, BloodRequest>> reportDonated(int id) =>
      safeCall(() => remote.setPledge(id, PledgeStatus.donated));

  @override
  Future<Either<Failure, BloodRequest>> cancelPledge(int id) =>
      safeCall(() => remote.setPledge(id, PledgeStatus.cancelled));
}
