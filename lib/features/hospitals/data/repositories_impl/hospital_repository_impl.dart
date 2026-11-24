import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/hospital.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../datasources/hospital_remote_datasource.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  HospitalRepositoryImpl(this.remote);
  final HospitalRemoteDataSource remote;

  @override
  Future<Either<Failure, List<Hospital>>> inGovernorate(String governorateId) =>
      safeCall(() => remote.inGovernorate(governorateId));
}
