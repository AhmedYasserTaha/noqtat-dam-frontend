import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/blood_request_draft.dart';

abstract interface class BloodRequestRepository {
  Future<Either<Failure, String>> create(BloodRequestDraft draft);
  Future<Either<Failure, Unit>> pledge(String postId);
}
