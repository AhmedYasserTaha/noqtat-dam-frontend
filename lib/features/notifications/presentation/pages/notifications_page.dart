import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home_feed/presentation/cubit/feed_cubit.dart';
import '../cubit/notifications_cubit.dart';

class NotificationsPageView extends StatefulWidget {
  const NotificationsPageView({super.key});
  @override
  State<NotificationsPageView> createState() => _NotificationsPageViewState();
}

class _NotificationsPageViewState extends State<NotificationsPageView> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final s = context.watch<NotificationsCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.notificationsTitle),
        actions: [
          if (s.unreadCount > 0)
            TextButton(
              key: const Key('mark-all-read'),
              onPressed: () async {
                await context.read<NotificationsCubit>().markAllRead();
                if (context.mounted) context.read<FeedCubit>().load();
              },
              child: Text(t.markAllRead),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 512),
          child: s.loading
              ? const CircularProgressIndicator()
              : s.failure != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(failureMessage(t, s.failure!)),
                    TextButton(
                      onPressed: () =>
                          context.read<NotificationsCubit>().load(),
                      child: Text(t.retry),
                    ),
                  ],
                )
              : s.items.isEmpty
              ? Text(t.notificationsEmpty)
              : ListView(
                  children: [
                    for (final n in s.items)
                      ListTile(
                        key: Key('notification-${n.id}'),
                        leading: Icon(
                          Icons.circle,
                          size: 10,
                          color: n.read ? Colors.transparent : AppColors.red,
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.read
                                ? FontWeight.w500
                                : FontWeight.w900,
                          ),
                        ),
                        subtitle: Text(n.body),
                        onTap: () {
                          context.read<NotificationsCubit>().markRead(n);
                          context.read<FeedCubit>().load();
                          context.go(
                            n.type == 'new_request' ? '/' : '/requests',
                          );
                        },
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
