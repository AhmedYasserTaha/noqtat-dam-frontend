import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications implements UseCase<NotificationsPage, int?> {
  GetNotifications(this.repository);
  final NotificationsRepository repository;
  @override
  Future<Either<Failure, NotificationsPage>> call(int? before) =>
      repository.list(before: before);
}

/// Pass ids to mark those, or null to mark everything read.
class MarkNotificationsRead implements UseCase<Unit, List<int>?> {
  MarkNotificationsRead(this.repository);
  final NotificationsRepository repository;
  @override
  Future<Either<Failure, Unit>> call(List<int>? ids) =>
      repository.markRead(ids: ids);
}
