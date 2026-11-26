import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/utils/request_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../blood_request/domain/entities/blood_request.dart';
import '../../domain/entities/home_data.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.child,
    this.dark = false,
    this.padding = const EdgeInsets.all(12),
  });
  final Widget child;
  final bool dark;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      gradient: dark
          ? const LinearGradient(
              colors: [Color(0xFF292524), Color(0xFF1C1917)],
            )
          : null,
      color: dark ? null : Colors.white,
      borderRadius: BorderRadius.circular(dark ? 22 : 16),
      border: dark ? null : Border.all(color: AppColors.border),
      boxShadow: dark
          ? null
          : [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
    ),
    child: child,
  );
}

class DonationReadinessCard extends StatelessWidget {
  const DonationReadinessCard({
    super.key,
    required this.isAvailable,
    required this.bloodType,
    required this.onChanged,
    this.loading = false,
  });
  final bool isAvailable, loading;
  final String bloodType;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FeedCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB91C1C), Color(0xFF991B1B)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              bloodType,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.yourBloodType,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAvailable
                            ? const Color(0xFF287447)
                            : AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        isAvailable ? t.availabilityLabel : t.unavailableNow,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 6),
              child: SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          Switch.adaptive(
            key: const Key('home-availability'),
            value: isAvailable,
            onChanged: loading ? null : onChanged,
            activeTrackColor: const Color(0xFF287447),
          ),
        ],
      ),
    );
  }
}

class UrgentRequestCard extends StatelessWidget {
  const UrgentRequestCard({
    super.key,
    required this.request,
    required this.onDonate,
    required this.onShare,
    this.onReport,
    this.onViewMine,
  });
  final BloodRequest request;
  final VoidCallback onDonate, onShare;
  final VoidCallback? onReport, onViewMine;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    const muted = Color(0xFFC8BFBD);
    final pledged = request.myPledge == PledgeStatus.onTheWay;
    final total = request.bagsNeeded.clamp(1, 12);
    final done = request.bagsCollected.clamp(0, total);
    return FeedCard(
      dark: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.redOnDark,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${urgencyLabel(t, request.urgency)} · ${t.closestRequest}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (request.deadline != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF504747)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    timeLeftLabel(t, request.deadline!, DateTime.now()),
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                request.bloodType,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: AppColors.redOnDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                  height: 1.15,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.bagsNeeded(request.bagsNeeded),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      key: const ValueKey('urgent-hospital'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.local_hospital_outlined,
                          color: muted,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request.hospitalName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppIcon(
                          AppIcons.locationPin,
                          color: muted,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                                  request.district?.of(lang),
                                  request.governorate?.of(lang),
                                ]
                                .whereType<String>()
                                .where((e) => e.isNotEmpty)
                                .join(' \u2022 '),
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    if (request.isVerified) ...[
                      const SizedBox(height: 5),
                      Text(
                        t.hospitalVerified,
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var index = 0; index < total; index++)
                Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsetsDirectional.only(
                      end: index == total - 1 ? 0 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: index < done
                          ? AppColors.redOnDark
                          : const Color(0xFF403636),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  t.collectedOf(request.bagsCollected, request.bagsNeeded),
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  t.onTheWayCount(request.onTheWayCount),
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ),
            ],
          ),
          if ((request.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              request.notes!.trim(),
              key: const ValueKey('urgent-notes'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: muted, fontSize: 12, height: 1.6),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.redGradient,
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    child: ElevatedButton(
                      onPressed: request.isMine ? onViewMine : onDonate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFF403636),
                        disabledForegroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppIcon(
                            AppIcons.bloodDropFilled,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 9),
                          Flexible(
                            child: Text(
                              request.isMine
                                  ? t.viewMyRequests
                                  : pledged
                                  ? t.viewPledge
                                  : t.iWillDonate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                width: 44,
                child: OutlinedButton(
                  onPressed: onShare,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: Color(0xFF504747)),
                  ),
                  child: AppIcon(
                    AppIcons.share,
                    color: Colors.white,
                    semanticLabel: t.shareRequest,
                  ),
                ),
              ),
              if (onReport != null)
                PopupMenuButton<String>(
                  key: Key('urgent-menu-${request.id}'),
                  iconColor: Colors.white,
                  onSelected: (_) => onReport!(),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'report', child: Text(t.reportAction)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _km(double d) => d < 10 ? d.toStringAsFixed(1) : d.round().toString();

class CompactRequestCard extends StatelessWidget {
  const CompactRequestCard({
    super.key,
    required this.request,
    required this.onDonate,
    this.onShare,
    this.onReport,
    this.distanceKm,
  });
  final BloodRequest request;
  final VoidCallback onDonate;
  final VoidCallback? onShare, onReport;

  /// Straight-line distance from the phone to the hospital pin, only set after
  /// the user opted in to sorting by distance.
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final urgent = request.urgency == Urgency.critical;
    final pledged = request.myPledge == PledgeStatus.onTheWay;
    final label = pledged ? t.viewPledge : t.donateAction;
    final progress = (request.bagsCollected / request.bagsNeeded.clamp(1, 20))
        .clamp(0.0, 1.0);
    return FeedCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: urgent
                      ? const LinearGradient(
                          colors: [Color(0xFFB91C1C), Color(0xFF991B1B)],
                        )
                      : null,
                  color: urgent ? null : AppColors.red.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  request.bloodType,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: urgent ? Colors.white : AppColors.red,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            t.bagsNeeded(request.bagsNeeded),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (request.urgency != Urgency.scheduled) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: urgent
                                  ? AppColors.red.withValues(alpha: 0.1)
                                  : AppColors.subtle,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '● ${urgencyLabel(t, request.urgency)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: urgent ? AppColors.red : AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.local_hospital_outlined,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${request.hospitalName} · ${placeLine(request, lang)}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                              if (distanceKm != null)
                                Text(
                                  // Pins are volunteer-edited map data; say so unless a
                                  // reviewer confirmed this one.
                                  (request.hospitalLocation?.isVerified ??
                                          false)
                                      ? t.distanceApprox(_km(distanceKm!))
                                      : t.distanceApproxUnreviewed(
                                          _km(distanceKm!),
                                        ),
                                  key: const Key('distance-label'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onShare != null || (onReport != null && !request.isMine))
                PopupMenuButton<String>(
                  key: Key('request-menu-${request.id}'),
                  padding: EdgeInsets.zero,
                  onSelected: (v) =>
                      v == 'share' ? onShare?.call() : onReport?.call(),
                  itemBuilder: (_) => [
                    if (onShare != null)
                      PopupMenuItem(
                        value: 'share',
                        child: Text(t.shareRequest),
                      ),
                    if (onReport != null && !request.isMine)
                      PopupMenuItem(
                        value: 'report',
                        child: Text(t.reportAction),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: AppColors.subtle,
            color: urgent ? AppColors.red : AppColors.ink,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: (urgent && !request.isMine)
                    ? AppColors.redGradient
                    : null,
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
              child: ElevatedButton(
                onPressed: request.isMine ? null : onDonate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (urgent && !request.isMine)
                      ? Colors.transparent
                      : urgent
                      ? AppColors.red
                      : AppColors.ink,
                  shadowColor: (urgent && !request.isMine)
                      ? Colors.transparent
                      : null,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  disabledForegroundColor: AppColors.muted,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    this.onReact,
    this.onReport,
    this.onDelete,
  });
  final CommunityPost post;
  final ValueChanged<PostReaction>? onReact;
  final VoidCallback? onReport, onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFFFF0EE),
                      child: AppIcon(
                        AppIcons.userOutline,
                        color: AppColors.muted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            DateFormat.yMMMd(locale)
                                .add_jm()
                                .format(post.createdAt.toLocal()),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (post.isMine ? onDelete != null : onReport != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: PopupMenuButton<String>(
                      key: Key('post-menu-${post.id}'),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (v) =>
                          v == 'delete' ? onDelete?.call() : onReport?.call(),
                      itemBuilder: (_) => [
                        if (post.isMine)
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(t.deletePostAction),
                          )
                        else
                          PopupMenuItem(
                            value: 'report',
                            child: Text(t.reportAction),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            post.text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ReactionButton(
                key: Key('like-${post.id}'),
                selectedColor: Colors.black,
                icon: post.myReaction == PostReaction.like
                    ? Icons.thumb_up
                    : Icons.thumb_up_outlined,
                label: t.likeAction,
                count: post.likes,
                selected: post.myReaction == PostReaction.like,
                onTap: onReact == null
                    ? null
                    : () => onReact!(PostReaction.like),
              ),
              const SizedBox(width: 8),
              _ReactionButton(
                key: Key('dislike-${post.id}'),
                icon: post.myReaction == PostReaction.dislike
                    ? Icons.thumb_down
                    : Icons.thumb_down_outlined,
                label: t.dislikeAction,
                count: post.dislikes,
                selected: post.myReaction == PostReaction.dislike,
                onTap: onReact == null
                    ? null
                    : () => onReact!(PostReaction.dislike),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.selectedColor = AppColors.red,
  });
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback? onTap;
  final Color selectedColor;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32, minWidth: 48),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? selectedColor.withValues(alpha: 0.08)
              : const Color(0xFFF7F7F7),
          border: Border.all(
            color: selected
                ? selectedColor.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? selectedColor : AppColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: selected ? selectedColor : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
