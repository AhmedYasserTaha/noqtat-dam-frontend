import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

enum AppNavDestination { home, map, requests, profile }

/// Presentation only: routing is supplied by the surrounding app shell.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onCreate,
  });
  final AppNavDestination selected;
  final ValueChanged<AppNavDestination> onSelected;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _item(
                    context,
                    AppNavDestination.home,
                    t.home,
                    AppIcons.homeOutline,
                    AppIcons.homeFilled,
                  ),
                  _item(
                    context,
                    AppNavDestination.map,
                    t.mapTab,
                    AppIcons.locationPin,
                    AppIcons.locationPin,
                  ),
                  Expanded(
                    child: Center(
                      heightFactor: 1,
                      child: SizedBox(
                        width: 54,
                        height: 54,
                        child: IconButton(
                          tooltip: t.createRequestAction,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                          ),
                          onPressed: onCreate,
                          icon: const AppIcon(
                            AppIcons.plus,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _item(
                    context,
                    AppNavDestination.requests,
                    t.myRequestsTab,
                    AppIcons.bloodDropOutline,
                    AppIcons.bloodDropFilled,
                  ),
                  _item(
                    context,
                    AppNavDestination.profile,
                    t.myAccountTab,
                    AppIcons.userOutline,
                    AppIcons.userFilled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    AppNavDestination destination,
    String label,
    String icon,
    String activeIcon,
  ) {
    final active = selected == destination;
    final color = active ? Colors.white : const Color(0xFFA89F9D);
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        label: label,
        child: InkWell(
          onTap: () => onSelected(destination),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(active ? activeIcon : icon, color: color, size: 23),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
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
