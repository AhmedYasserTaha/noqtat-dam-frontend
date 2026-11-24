import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.postId,
  });
  final int id;

  /// new_request, pledge, pledge_update or request_status.
  final String type;
  final int? postId;
  final String title, body;
  final bool read;
  final DateTime createdAt;

  AppNotification asRead() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    read: true,
    createdAt: createdAt,
    postId: postId,
  );

  @override
  List<Object?> get props => [id, type, postId, title, body, read, createdAt];
}

class NotificationsPage extends Equatable {
  const NotificationsPage(this.items, this.unreadCount, this.nextBefore);
  final List<AppNotification> items;
  final int unreadCount;
  final int? nextBefore;
  @override
  List<Object?> get props => [items, unreadCount, nextBefore];
}
