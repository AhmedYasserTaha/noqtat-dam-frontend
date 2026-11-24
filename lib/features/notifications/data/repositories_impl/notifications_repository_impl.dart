import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this.remote);
  final NotificationsRemoteDataSource remote;
  @override
  Future<Either<Failure, NotificationsPage>> list({int? before}) =>
      safeCall(() => remote.list(before: before));
  @override
  Future<Either<Failure, Unit>> markRead({List<int>? ids}) =>
      safeCall(() async {
        await remote.markRead(ids: ids);
        return unit;
      });
}
