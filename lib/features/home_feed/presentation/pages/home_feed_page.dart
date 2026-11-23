import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/egypt_location_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/request_text.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../domain/entities/home_data.dart';
import '../cubit/feed_cubit.dart';
import '../widgets/feed_cards.dart';
import '../widgets/pledge_sheet.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});
  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  static const _filters = RequestFilter.values;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().load();
    context.read<FeedCubit>().load();
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

  void _snack(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  void _notice(String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.8,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.closeLocations),
            ),
          ],
        ),
      ),
    );
  }

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
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ProfileCubit>().load();
            await context.read<FeedCubit>().load();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              Row(
                children: [
                  const AppIcon(
                    AppIcons.bloodDropFilled,
                    color: AppColors.red,
                    size: 25,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.authBrand,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 21,
                      ),
                    ),
                  ),
                  Flexible(
                    child: OutlinedButton(
                      onPressed: _chooseLocation,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 44),
                        foregroundColor: AppColors.ink,
                        shape: const StadiumBorder(),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(
                            AppIcons.locationPin,
                            color: AppColors.ink,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              city ?? t.chooseLocationChip,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () =>
                          _notice(t.notificationsTitle, t.noNotificationsYet),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                      ),
                      child: const AppIcon(
                        AppIcons.bell,
                        color: AppColors.ink,
                        size: 21,
                      ),
                    ),
                  ),
                ],
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
                  onShare: () async {
                    await Clipboard.setData(
                      ClipboardData(text: shareText(t, urgent, lang)),
                    );
                    if (!context.mounted) return;
                    _snack(t.requestCopied);
                  },
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
                  CompactRequestCard(request: r, onDonate: () => _donate(r)),
                  const SizedBox(height: 10),
                ],
                if (feed.query.filter == RequestFilter.all)
                  for (final post
                      in home?.posts ?? const <CommunityPost>[]) ...[
                    CommunityPostCard(post: post),
                    const SizedBox(height: 10),
                  ],
              ],
            ],
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
