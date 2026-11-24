import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/blood_request.dart';
import '../entities/donor_pledge.dart';
import '../repositories/blood_request_repository.dart';

class CreateBloodRequest implements UseCase<BloodRequest, BloodRequestDraft> {
  CreateBloodRequest(this.repository);
  final BloodRequestRepository repository;
  @override
  Future<Either<Failure, BloodRequest>> call(BloodRequestDraft draft) =>
      repository.create(draft);
}

class GetMyRequests implements UseCase<List<BloodRequest>, RequestTab> {
  GetMyRequests(this.repository);
  final BloodRequestRepository repository;
  @override
  Future<Either<Failure, List<BloodRequest>>> call(RequestTab tab) =>
      repository.mine(tab);
}

class UpdateRequestParams {
  const UpdateRequestParams(this.id, {this.bagsCollected, this.status});
  final int id;
  final int? bagsCollected;
  final RequestStatus? status;
}

class UpdateMyRequest implements UseCase<BloodRequest, UpdateRequestParams> {
  UpdateMyRequest(this.repository);
  final BloodRequestRepository repository;
  @override
  Future<Either<Failure, BloodRequest>> call(UpdateRequestParams p) =>
      repository.update(p.id, bagsCollected: p.bagsCollected, status: p.status);
}

class PledgeToDonate implements UseCase<BloodRequest, int> {
  PledgeToDonate(this.repository);
  final BloodRequestRepository repository;
  @override
  Future<Either<Failure, BloodRequest>> call(int id) => repository.pledge(id);
}

class ReportDonated implements UseCase<BloodRequest, int> {
  ReportDonated(this.repository);
  final BloodRequestRepository repository;
  @override
  Future<Either<Failure, BloodRequest>> call(int id) =>
      repository.reportDonated(id);
}

class CancelPledge implements UseCase<BloodRequest, int> {
  CancelPledge(this.repository);
  final BloodRequestRepository repository;
  @override
  Future<Either<Failure, BloodRequest>> call(int id) =>
      repository.cancelPledge(id);
}

class GetRequestPledges implements UseCase<List<DonorPledge>, int> {
  GetRequestPledges(this.repository);
  final BloodRequestRepository repository;
  @override
  Future<Either<Failure, List<DonorPledge>>> call(int requestId) =>
      repository.pledges(requestId);
}
