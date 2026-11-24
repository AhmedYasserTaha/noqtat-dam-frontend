import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/hospital.dart';

abstract interface class HospitalRepository {
  Future<Either<Failure, List<Hospital>>> inGovernorate(String governorateId);
}
