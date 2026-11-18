import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/blood_request_draft.dart';
import '../repositories/blood_request_repository.dart';

class CreateBloodRequest implements UseCase<String, BloodRequestDraft> {
  CreateBloodRequest(this.repository);
  final BloodRequestRepository repository;
  @override
  Future<Either<Failure, String>> call(BloodRequestDraft draft) =>
      repository.create(draft);
}

class PledgeToDonate implements UseCase<Unit, String> {
  PledgeToDonate(this.repository);
  final BloodRequestRepository repository;
  @override
  Future<Either<Failure, Unit>> call(String id) => repository.pledge(id);
}
