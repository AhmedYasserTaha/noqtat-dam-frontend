import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this.api);
  final ApiClient api;

  Future<NotificationsPage> list({int? before}) async {
    final j = await api.get(
      ApiConstants.notifications,
      query: {'before': before},
    );
    return NotificationsPage(
      [
        for (final n in j['items'] as List<dynamic>)
          AppNotification(
            id: (n as Json)['id'] as int,
            type: n['type'] as String,
            postId: n['postId'] as int?,
            title: n['title'] as String? ?? '',
            body: n['body'] as String? ?? '',
            read: n['read'] as bool? ?? false,
            createdAt: DateTime.parse(n['createdAt'] as String),
          ),
      ],
      j['unreadCount'] as int? ?? 0,
      j['nextBefore'] as int?,
    );
  }

  Future<void> markRead({List<int>? ids}) async {
    await api.post(
      ApiConstants.notificationsRead,
      body: ids == null ? {'all': true} : {'ids': ids},
    );
  }
}
