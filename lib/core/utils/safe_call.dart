import 'package:fpdart/fpdart.dart';

import '../errors/failures.dart';
import '../network/api_client.dart';

/// Runs [body] and converts [ApiException] / unexpected errors to `Left`.
Future<Either<Failure, T>> safeCall<T>(Future<T> Function() body) async {
  try {
    return Right(await body());
  } on ApiException catch (e) {
    return Left(e.failure);
  } on Object {
    return const Left(UnexpectedFailure());
  }
}
