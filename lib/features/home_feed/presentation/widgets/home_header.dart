import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.city,
    required this.onChooseLocation,
    required this.onNotifications,
    this.unreadNotifications = 0,
  });

  final String? city;
  final VoidCallback onChooseLocation;
  final VoidCallback onNotifications;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const AppIcon(
            AppIcons.bloodDropFilled,
            color: AppColors.red,
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                Semantics(
                  button: true,
                  label: t.chooseLocationChip,
                  child: InkWell(
                    onTap: onChooseLocation,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(
                            AppIcons.locationPin,
                            size: 14,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              city ?? t.chooseLocationChip,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 17,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox.square(
            dimension: 42,
            child: IconButton.outlined(
              tooltip: t.notificationsTitle,
              onPressed: onNotifications,
              style: IconButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.white,
              ),
              icon: Badge(
                key: const Key('bell-badge'),
                isLabelVisible: unreadNotifications > 0,
                label: Text('$unreadNotifications'),
                child: const AppIcon(
                  AppIcons.bell,
                  color: AppColors.ink,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
