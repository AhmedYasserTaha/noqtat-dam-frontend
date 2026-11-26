import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/device_location.dart';
import '../../../../core/widgets/egypt_location_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/request_text.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/share_service.dart';
import '../../../../core/utils/push_registrar.dart';
import '../../domain/entities/home_data.dart';
import '../cubit/feed_cubit.dart';
import '../widgets/feed_cards.dart';
import '../widgets/home_header.dart';
import '../widgets/pledge_sheet.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});
  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  static const _filters = RequestFilter.values;

  /// Phone position, kept only in memory after the user taps "closest first".
  /// Never sent to the server.
  ({double lat, double lon})? _position;
  bool _sortByDistance = false;
  bool _locating = false;
  bool _updatingAvailability = false;

  Future<void> _setAvailability(bool value) async {
    if (_updatingAvailability) return;
    setState(() => _updatingAvailability = true);
    final cubit = context.read<ProfileCubit>();
    final ok = await cubit.update(ProfileUpdate(isAvailable: value));
    if (!mounted) return;
    setState(() => _updatingAvailability = false);
    if (!ok && cubit.state.actionFailure != null) {
      _snack(
        failureMessage(
          AppLocalizations.of(context)!,
          cubit.state.actionFailure!,
        ),
      );
    }
  }

  final _urgentIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _urgentIndex.dispose();
    super.dispose();
  }

  Future<void> _toggleDistance() async {
    final t = AppLocalizations.of(context)!;
    if (_sortByDistance) {
      setState(() => _sortByDistance = false);
      return;
    }
    if (_position != null) {
      setState(() => _sortByDistance = true);
      return;
    }
    setState(() => _locating = true);
    final r = await getIt<DeviceLocation>().current();
    if (!mounted) return;
    setState(() => _locating = false);
    if (r.outcome == LocationOutcome.ok) {
      setState(() {
        _position = (lat: r.latitude!, lon: r.longitude!);
        _sortByDistance = true;
      });
      return;
    }
    final message = switch (r.outcome) {
      LocationOutcome.denied => t.locationDenied,
      LocationOutcome.deniedForever => t.locationDeniedForever,
      LocationOutcome.serviceOff => t.locationServiceOff,
      _ => t.locationFailed,
    };
    // Manual fallback: the existing area picker.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: t.changeMyArea,
          onPressed: _chooseLocation,
        ),
      ),
    );
  }

  double? _distanceTo(BloodRequest r) {
    final p = _position;
    final h = r.hospitalLocation;
    if (p == null || h == null) return null;
    return distanceKm(p.lat, p.lon, h.latitude, h.longitude);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) getIt<PushRegistrar>().onSignedIn();
    });
    context.read<ProfileCubit>().load(reuseExisting: true);
    context.read<FeedCubit>().load();
  }

  Future<void> _donate(BloodRequest r) async {
    final feed = context.read<FeedCubit>();
    var current = r;
    if (r.myPledge == null || r.myPledge == PledgeStatus.cancelled) {
      final pledged = await feed.pledge(r.id);
      if (!mounted) return;
      if (pledged == null) {
        final f = feed.state.actionFailure;
        if (f != null) _snack(failureMessage(AppLocalizations.of(context)!, f));
        return;
      }
      current = pledged;
    }
    if (!mounted) return;
    final action = await showPledgeSheet(context, current);
    if (action == PledgeAction.donated) {
      await feed.reportDonated(current.id);
      if (mounted) context.read<ProfileCubit>().load();
    } else if (action == PledgeAction.cancel) {
      await feed.cancelPledge(current.id);
    }
  }

  Future<void> _share(BloodRequest r) async {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final text = shareText(t, r, lang);
    try {
      await getIt<ShareService>().shareText(text);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) _snack(t.shareFailedCopied);
    }
  }

  Future<void> _report(ReportTarget target, int id) async {
    final t = AppLocalizations.of(context)!;
    final reason = await showModalBottomSheet<ReportReason>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheet) {
        final labels = {
          ReportReason.spam: t.reportSpam,
          ReportReason.fake: t.reportFake,
          ReportReason.abusive: t.reportAbusive,
          ReportReason.sensitiveInfo: t.reportSensitive,
          ReportReason.other: t.reportOther,
        };
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.reportTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              for (final e in labels.entries)
                ListTile(
                  key: Key('report-${e.key.name}'),
                  title: Text(e.value),
                  onTap: () => Navigator.pop(sheet, e.key),
                ),
            ],
          ),
        );
      },
    );
    if (reason == null || !mounted) return;
    final feed = context.read<FeedCubit>();
    final ok = await feed.report(target, id, reason);
    if (!mounted) return;
    if (ok) {
      _snack(t.reportDone);
    } else if (feed.state.actionFailure != null) {
      _snack(failureMessage(t, feed.state.actionFailure!));
    }
  }

  void _snack(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  void _chooseLocation() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EgyptLocationFields(
              onChanged: (governorate, district) async {
                if (governorate == null || district == null) return;
                Navigator.pop(sheetContext);
                final ok = await context.read<ProfileCubit>().update(
                  ProfileUpdate(
                    governorateId: governorate.id,
                    districtId: district.id,
                  ),
                );
                if (ok && mounted) context.read<FeedCubit>().load();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final filterLabels = [
      t.filterAll,
      t.urgentLabel,
      t.filterMyBlood,
      t.filterNearby,
    ];
    final profile = context.watch<ProfileCubit>().state.profile;
    final feed = context.watch<FeedCubit>().state;
    final home = feed.home;
    final city = profile?.district?.of(lang) ?? profile?.governorate?.of(lang);
    final selected = _filters.indexOf(feed.query.filter);
    final urgentRequests = feed.query.filter == RequestFilter.all
        ? <int, BloodRequest>{
            if (home?.closestUrgent case final request?) request.id: request,
            for (final request in feed.requests)
              if (request.urgency == Urgency.critical &&
                  request.status == RequestStatus.open)
                request.id: request,
          }.values.toList()
        : <BloodRequest>[];
    final urgentIds = urgentRequests.map((r) => r.id).toSet();
    var list = feed.requests.where((r) => !urgentIds.contains(r.id)).toList();
    if (_sortByDistance && _position != null) {
      // Stable: requests without a hospital pin keep their order, at the end.
      final indexed = [for (var i = 0; i < list.length; i++) (i, list[i])];
      indexed.sort((a, b) {
        final da = _distanceTo(a.$2), db = _distanceTo(b.$2);
        if (da == null && db == null) return a.$1.compareTo(b.$1);
        if (da == null) return 1;
        if (db == null) return -1;
        final c = da.compareTo(db);
        return c != 0 ? c : a.$1.compareTo(b.$1);
      });
      list = [for (final e in indexed) e.$2];
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.axis == Axis.vertical &&
                n.metrics.extentAfter < 300) {
              final f = context.read<FeedCubit>();
              if (f.state.loadMoreFailure == null) f.loadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileCubit>().load();
              await context.read<FeedCubit>().load();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              children:
                  <Widget>[
                        HomeHeader(
                          city: city,
                          unreadNotifications: home?.unreadNotifications ?? 0,
                          onChooseLocation: _chooseLocation,
                          onNotifications: () => context.push('/notifications'),
                        ),
                        const SizedBox(height: 12),
                        if (home != null && profile != null) ...[
                          DonationReadinessCard(
                            isAvailable: profile.isAvailable,
                            bloodType: profile.bloodType,
                            loading: _updatingAvailability,
                            onChanged: _setAvailability,
                          ),
                          const SizedBox(height: 12),
                        ],
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (
                                var index = 0;
                                index < _filters.length;
                                index++
                              )
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 8,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(filterLabels[index]),
                                    selected: selected == index,
                                    showCheckmark: false,
                                    selectedColor: AppColors.ink,
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color: selected == index
                                          ? Colors.white
                                          : AppColors.muted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: const StadiumBorder(),
                                    side: BorderSide(
                                      color: selected == index
                                          ? AppColors.ink
                                          : AppColors.border,
                                    ),
                                    onSelected: (_) =>
                                        context.read<FeedCubit>().load(
                                          FeedQuery(filter: _filters[index]),
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (urgentRequests.isNotEmpty) ...[
                          LayoutBuilder(
                            key: const Key('urgent-edge-to-edge'),
                            builder: (context, constraints) =>
                                NotificationListener<ScrollNotification>(
                                  onNotification: (notification) {
                                    if (notification.metrics.axis ==
                                        Axis.horizontal) {
                                      final step =
                                          (constraints.maxWidth - 32) * 0.94 +
                                          10;
                                      _urgentIndex.value =
                                          (notification.metrics.pixels / step)
                                              .round()
                                              .clamp(
                                                0,
                                                urgentRequests.length - 1,
                                              );
                                    }
                                    return false;
                                  },
                                  child: SingleChildScrollView(
                                    key: const Key('urgent-requests-scroll'),
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 16,
                                      end: 16,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (final urgent in urgentRequests)
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              end:
                                                  urgentRequests.length > 1 &&
                                                      urgent.id !=
                                                          urgentRequests.last.id
                                                  ? 10
                                                  : 0,
                                            ),
                                            child: SizedBox(
                                              width:
                                                  (constraints.maxWidth - 32) *
                                                  (urgentRequests.length > 1
                                                      ? 0.94
                                                      : 1),
                                              child: UrgentRequestCard(
                                                request: urgent,
                                                onDonate: () => _donate(urgent),
                                                onShare: () => _share(urgent),
                                                onViewMine: () =>
                                                    context.push('/requests'),
                                                onReport: urgent.isMine
                                                    ? null
                                                    : () => _report(
                                                        ReportTarget.request,
                                                        urgent.id,
                                                      ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                          ),
                          if (urgentRequests.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ValueListenableBuilder<int>(
                                valueListenable: _urgentIndex,
                                builder: (context, selected, _) => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (
                                      var i = 0;
                                      i < urgentRequests.length;
                                      i++
                                    )
                                      AnimatedContainer(
                                        key: Key('urgent-dot-$i'),
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        width:
                                            i ==
                                                selected.clamp(
                                                  0,
                                                  urgentRequests.length - 1,
                                                )
                                            ? 16
                                            : 6,
                                        height: 6,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              i ==
                                                  selected.clamp(
                                                    0,
                                                    urgentRequests.length - 1,
                                                  )
                                              ? AppColors.red
                                              : AppColors.border,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                        if (list.length > 1 || _sortByDistance)
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton.icon(
                              key: const Key('sort-distance'),
                              onPressed: _locating ? null : _toggleDistance,
                              icon: _locating
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      _sortByDistance
                                          ? Icons.near_me_rounded
                                          : Icons.near_me_outlined,
                                      size: 18,
                                    ),
                              label: Text(
                                _sortByDistance
                                    ? '${t.sortByDistanceOn} · ${t.sortByDistanceOff}'
                                    : t.sortByDistance,
                              ),
                            ),
                          ),
                        if (_sortByDistance)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              t.distanceNote,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (feed.status == FeedStatus.loading &&
                            feed.home == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (feed.status == FeedStatus.failure)
                          _message(
                            failureMessage(t, feed.failure!),
                            action: TextButton(
                              onPressed: () => context.read<FeedCubit>().load(),
                              child: Text(t.retry),
                            ),
                          )
                        else ...[
                          if (list.isEmpty && urgentRequests.isEmpty)
                            _emptyState(t, feed.query.filter, profile),
                          for (final r in list) ...[
                            CompactRequestCard(
                              request: r,
                              distanceKm: _sortByDistance
                                  ? _distanceTo(r)
                                  : null,
                              onDonate: () => _donate(r),
                              onShare: () => _share(r),
                              onReport: () =>
                                  _report(ReportTarget.request, r.id),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (feed.query.filter == RequestFilter.all)
                            for (final post in feed.posts) ...[
                              CommunityPostCard(
                                post: post,
                                onReact: (r) =>
                                    context.read<FeedCubit>().react(post.id, r),
                                onReport: () =>
                                    _report(ReportTarget.post, post.id),
                                onDelete: () async {
                                  if (await context
                                          .read<FeedCubit>()
                                          .deletePost(post.id) &&
                                      mounted) {
                                    _snack(t.postDeleted);
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          if (feed.loadMoreFailure != null)
                            _message(
                              t.loadMoreFailed,
                              action: TextButton(
                                key: const Key('load-more-retry'),
                                onPressed: () =>
                                    context.read<FeedCubit>().loadMore(),
                                child: Text(t.retry),
                              ),
                            )
                          else if (feed.loadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (feed.hasMore &&
                              (feed.query.filter == RequestFilter.all ||
                                  feed.requestsNext != null))
                            Center(
                              child: TextButton(
                                key: const Key('load-more'),
                                onPressed: () =>
                                    context.read<FeedCubit>().loadMore(),
                                child: Text(t.loadMore),
                              ),
                            ),
                        ],
                      ]
                      .map(
                        (child) => child.key == const Key('urgent-edge-to-edge')
                            ? child
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: child,
                              ),
                      )
                      .toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Empty list: say why and offer the next step instead of a dead end.
  Widget _emptyState(
    AppLocalizations t,
    RequestFilter filter,
    UserProfile? profile,
  ) {
    final feedCubit = context.read<FeedCubit>();
    if (filter == RequestFilter.all) {
      return _message(
        t.noRequestsYet,
        action: TextButton(
          key: const Key('empty-refresh'),
          onPressed: () => feedCubit.load(),
          child: Text(t.noRequestsRefresh),
        ),
      );
    }
    final needsArea =
        filter == RequestFilter.nearby && profile?.governorate == null;
    return _message(
      needsArea ? t.nearbyNeedsArea : t.noRequestsFiltered,
      action: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          if (needsArea || filter == RequestFilter.nearby)
            TextButton(
              key: const Key('empty-change-area'),
              onPressed: _chooseLocation,
              child: Text(t.changeMyArea),
            ),
          TextButton(
            key: const Key('empty-show-all'),
            onPressed: () => feedCubit.load(const FeedQuery()),
            child: Text(t.showAllRequests),
          ),
        ],
      ),
    );
  }

  Widget _message(String text, {Widget? action}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        ?action,
      ],
    ),
  );
}
