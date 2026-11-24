import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/notifications_usecases.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.loading = true,
    this.items = const [],
    this.unreadCount = 0,
    this.nextBefore,
    this.failure,
  });
  final bool loading;
  final List<AppNotification> items;
  final int unreadCount;
  final int? nextBefore;
  final Failure? failure;
  @override
  List<Object?> get props => [loading, items, unreadCount, nextBefore, failure];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._get, this._mark) : super(const NotificationsState());
  final GetNotifications _get;
  final MarkNotificationsRead _mark;

  Future<void> load() async {
    emit(const NotificationsState());
    final r = await _get(null);
    if (isClosed) return;
    r.fold(
      (f) => emit(NotificationsState(loading: false, failure: f)),
      (p) => emit(
        NotificationsState(
          loading: false,
          items: p.items,
          unreadCount: p.unreadCount,
          nextBefore: p.nextBefore,
        ),
      ),
    );
  }

  Future<void> markRead(AppNotification n) async {
    if (n.read) return;
    emit(
      NotificationsState(
        loading: false,
        items: [for (final i in state.items) i.id == n.id ? i.asRead() : i],
        unreadCount: (state.unreadCount - 1).clamp(0, 1 << 30),
        nextBefore: state.nextBefore,
      ),
    );
    await _mark([n.id]);
  }

  Future<void> markAllRead() async {
    final r = await _mark(null);
    if (isClosed || r.isLeft()) return;
    emit(
      NotificationsState(
        loading: false,
        items: [for (final i in state.items) i.asRead()],
        nextBefore: state.nextBefore,
      ),
    );
  }
}
