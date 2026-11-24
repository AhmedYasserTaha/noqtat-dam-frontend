import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hospital.dart';
import '../repositories/hospital_repository.dart';

class GetHospitals implements UseCase<List<Hospital>, String> {
  GetHospitals(this.repository);
  final HospitalRepository repository;
  @override
  Future<Either<Failure, List<Hospital>>> call(String governorateId) =>
      repository.inGovernorate(governorateId);
}
