import 'package:fpdart/fpdart.dart';

import '../errors/failures.dart';

abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {
  const NoParams();
}
