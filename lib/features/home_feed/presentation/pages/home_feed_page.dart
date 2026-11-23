import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/egypt_location_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/feed_cards.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});
  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  int _filter = 0;
  String? _city;

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
              onChanged: (governorate, district) {
                if (district == null) return;
                setState(
                  () => _city = district.name(
                    Localizations.localeOf(context).languageCode,
                  ),
                );
                Navigator.pop(sheetContext);
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
    final filters = [
      t.filterAll,
      t.urgentLabel,
      t.filterMyBlood,
      t.filterNearby,
    ];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512),
        child: ListView(
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
                            _city ?? t.mansouraCity,
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
                        _notice(t.notificationsTitle, t.noDemoNotifications),
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
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 10),
              child: Text(
                t.demoFeedLabel,
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ),
            const DonationReadinessCard(),
            const SizedBox(height: 12),
            UrgentRequestCard(
              onDonate: () => _notice(t.iWillDonate, t.demoDonationNotice),
              onShare: () async {
                await Clipboard.setData(ClipboardData(text: t.demoShareText));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(t.requestCopied)));
              },
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < filters.length; index++)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text(filters[index]),
                        selected: _filter == index,
                        showCheckmark: false,
                        selectedColor: AppColors.ink,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _filter == index
                              ? Colors.white
                              : AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: _filter == index
                              ? AppColors.ink
                              : AppColors.border,
                        ),
                        onSelected: (_) => setState(() => _filter = index),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_filter == 0 || _filter == 1) ...[
              CompactRequestCard(
                bloodType: 'B-',
                title: t.twoBagsTitle,
                subtitle: t.talkhaHospitalDistance,
                urgent: true,
                onDonate: () => _notice(t.donateAction, t.demoDonationNotice),
              ),
              const SizedBox(height: 12),
            ],
            if (_filter == 0) ...[
              const CommunityPostCard(),
              const SizedBox(height: 10),
            ],
            if (_filter == 0 || _filter == 3) ...[
              CompactRequestCard(
                bloodType: 'A+',
                title: t.plateletsTitle,
                subtitle: t.salamHospitalDistance,
                onDonate: () => _notice(t.donateAction, t.demoDonationNotice),
              ),
            ],
            if (_filter == 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  t.matchingFeaturedRequest,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
