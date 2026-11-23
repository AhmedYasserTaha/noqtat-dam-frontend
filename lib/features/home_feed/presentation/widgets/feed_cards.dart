import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../l10n/app_localizations.dart';

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
      color: dark ? AppColors.ink : Colors.white,
      borderRadius: BorderRadius.circular(dark ? 22 : 16),
      border: dark ? null : Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class DonationReadinessCard extends StatelessWidget {
  const DonationReadinessCard({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FeedCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 1.7),
            ),
            child: const Text(
              'O-',
              textDirection: TextDirection.ltr,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.readyToDonate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  t.donationHistoryDemo,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const AppIcon(AppIcons.check, color: AppColors.ink, size: 22),
        ],
      ),
    );
  }
}

class UrgentRequestCard extends StatelessWidget {
  const UrgentRequestCard({
    super.key,
    required this.onDonate,
    required this.onShare,
  });
  final VoidCallback onDonate, onShare;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    const muted = Color(0xFFC8BFBD);
    return FeedCard(
      dark: true,
      child: Column(
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
                  t.closestUrgentRequest,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF504747)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t.threeHoursLeft,
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
              const Text(
                'O-',
                textDirection: TextDirection.ltr,
                style: TextStyle(
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
                      t.threeBagsNeeded,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                            t.mansouraHospitalDistance,
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      t.hospitalVerified,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var index = 0; index < 3; index++)
                Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: index == 0
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
              Text(
                t.oneOfThreeCollected,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              Text(
                t.twoOnTheWay,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onDonate,
                    style: ElevatedButton.styleFrom(elevation: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppIcon(
                          AppIcons.bloodDropFilled,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          t.iWillDonate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
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
            ],
          ),
        ],
      ),
    );
  }
}

class CompactRequestCard extends StatelessWidget {
  const CompactRequestCard({
    super.key,
    required this.bloodType,
    required this.title,
    required this.subtitle,
    required this.onDonate,
    this.urgent = false,
  });
  final String bloodType, title, subtitle;
  final bool urgent;
  final VoidCallback onDonate;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FeedCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: urgent ? AppColors.red : const Color(0xFFF2ECE9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              bloodType,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: urgent ? Colors.white : AppColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                if (urgent)
                  Text(
                    '● ${t.urgentLabel}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.red,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            height: 44,
            child: urgent
                ? ElevatedButton(
                    onPressed: onDonate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      t.donateAction,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onDonate,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.ink),
                    ),
                    child: Text(
                      t.donateAction,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FeedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE4D9D4),
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
                      t.demoDonorName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      t.twoHoursAgo,
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
          const SizedBox(height: 12),
          Text(
            t.demoDonationPost,
            style: const TextStyle(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}
