import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationsRepository {
  Future<Either<Failure, NotificationsPage>> list({int? before});
  Future<Either<Failure, Unit>> markRead({List<int>? ids});
}
