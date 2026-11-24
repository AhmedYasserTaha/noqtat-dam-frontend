import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
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

class _HomeFeedPageState extends State<HomeFeedPage>
    with WidgetsBindingObserver {
  static const _filters = RequestFilter.values;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) getIt<PushRegistrar>().onSignedIn();
    });
    context.read<ProfileCubit>().load();
    context.read<FeedCubit>().load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        mounted &&
        ModalRoute.of(context)?.isCurrent == true) {
      getIt<PushRegistrar>().onSignedIn();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _donate(BloodRequest r) async {
    final feed = context.read<FeedCubit>();
    var current = r;
    if (r.myPledge != PledgeStatus.onTheWay) {
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
    final urgent = home?.closestUrgent;
    // The featured urgent request is also in the list; skip the duplicate.
    final list = feed.requests.where((r) => r.id != urgent?.id).toList();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 300) {
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              children: [
                HomeHeader(
                  city: city,
                  unreadNotifications: home?.unreadNotifications ?? 0,
                  onChooseLocation: _chooseLocation,
                  onNotifications: () => context.push('/notifications'),
                ),
                const SizedBox(height: 12),
                if (home != null && profile != null) ...[
                  DonationReadinessCard(
                    readiness: home.readiness,
                    bloodType: profile.bloodType,
                  ),
                  const SizedBox(height: 12),
                ],
                if (urgent != null) ...[
                  UrgentRequestCard(
                    request: urgent,
                    onDonate: () => _donate(urgent),
                    onShare: () => _share(urgent),
                    onViewMine: () => context.push('/requests'),
                    onReport: urgent.isMine
                        ? null
                        : () => _report(ReportTarget.request, urgent.id),
                  ),
                  const SizedBox(height: 10),
                ],
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var index = 0; index < _filters.length; index++)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
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
                            onSelected: (_) => context.read<FeedCubit>().load(
                              FeedQuery(filter: _filters[index]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (feed.status == FeedStatus.loading && feed.home == null)
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
                  if (list.isEmpty && urgent == null) _message(t.noRequestsYet),
                  for (final r in list) ...[
                    CompactRequestCard(
                      request: r,
                      onDonate: () => _donate(r),
                      onShare: () => _share(r),
                      onReport: () => _report(ReportTarget.request, r.id),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (feed.query.filter == RequestFilter.all)
                    for (final post in feed.posts) ...[
                      CommunityPostCard(
                        post: post,
                        onReact: (r) =>
                            context.read<FeedCubit>().react(post.id, r),
                        onReport: () => _report(ReportTarget.post, post.id),
                        onDelete: () async {
                          if (await context.read<FeedCubit>().deletePost(
                                post.id,
                              ) &&
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
                        onPressed: () => context.read<FeedCubit>().loadMore(),
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
                        onPressed: () => context.read<FeedCubit>().loadMore(),
                        child: Text(t.loadMore),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
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
