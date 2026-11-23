import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../entities/home_data.dart';

abstract interface class FeedRepository {
  Future<Either<Failure, HomeData>> home();
  Future<Either<Failure, List<BloodRequest>>> feed(FeedQuery query);
}
