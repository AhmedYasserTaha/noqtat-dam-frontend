import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/widgets/app_icon.dart';
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
        leading: const BackButton(),
        title: Text(
          t.notificationsTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (s.unreadCount > 0)
            TextButton(
              key: const Key('mark-all-read'),
              onPressed: () async {
                await context.read<NotificationsCubit>().markAllRead();
                if (context.mounted) context.read<FeedCubit>().load();
              },
              child: Text(
                t.markAllRead,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const AppIcon(
                        AppIcons.bell,
                        size: 32,
                        color: AppColors.red,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      t.notificationsEmpty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<NotificationsCubit>().load(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    children: [
                      for (final n in s.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: n.read
                                ? Colors.white
                                : const Color(0xFFFFF7F6),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              key: Key('notification-${n.id}'),
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                context.read<NotificationsCubit>().markRead(n);
                                context.read<FeedCubit>().load();
                                context.go(
                                  n.type == 'new_request' ? '/' : '/requests',
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: n.read
                                        ? AppColors.ink.withValues(alpha: 0.07)
                                        : AppColors.red.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: n.read
                                            ? const Color(0xFFF5F5F5)
                                            : AppColors.red.withValues(
                                                alpha: 0.08,
                                              ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: AppIcon(
                                        n.type == 'new_request'
                                            ? AppIcons.bloodDropFilled
                                            : n.type == 'pledge'
                                            ? AppIcons.userOutline
                                            : n.type == 'pledge_update' ||
                                                  n.type == 'request_status'
                                            ? AppIcons.check
                                            : AppIcons.bell,
                                        size: 21,
                                        color: n.read
                                            ? AppColors.muted
                                            : AppColors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  n.title,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    height: 1.5,
                                                    fontWeight: n.read
                                                        ? FontWeight.w600
                                                        : FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              if (!n.read) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  width: 7,
                                                  height: 7,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: AppColors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            n.body,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              height: 1.7,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const AppIcon(
                                                AppIcons.clock,
                                                size: 12,
                                                color: AppColors.muted,
                                              ),
                                              const SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  DateFormat(
                                                    'd MMM · h:mm a',
                                                    Localizations.localeOf(
                                                      context,
                                                    ).toString(),
                                                  ).format(
                                                    n.createdAt.toLocal(),
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.muted,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
