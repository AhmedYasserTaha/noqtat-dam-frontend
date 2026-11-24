import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

enum AppNavDestination { home, requests, profile }

/// Routing is supplied by the surrounding app shell.
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
      minimum: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: .05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _item(
                    AppNavDestination.home,
                    t.home,
                    AppIcons.homeOutline,
                    AppIcons.homeFilled,
                  ),
                  _item(
                    AppNavDestination.requests,
                    t.myRequestsTab,
                    AppIcons.bloodDropOutline,
                    AppIcons.bloodDropFilled,
                  ),
                  _item(
                    AppNavDestination.profile,
                    t.myAccountTab,
                    AppIcons.userOutline,
                    AppIcons.userFilled,
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 28, color: AppColors.border),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 2,
                    child: Tooltip(
                      message: t.createRequestAction,
                      child: FilledButton(
                        onPressed: onCreate,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 46),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppIcon(
                              AppIcons.plus,
                              color: Colors.white,
                              size: 17,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                t.createRequestAction,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
    AppNavDestination destination,
    String label,
    String icon,
    String activeIcon,
  ) {
    final active = selected == destination;
    final color = active ? AppColors.red : AppColors.muted;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelected(destination),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.red.withValues(alpha: .08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: AppIcon(
                      active ? activeIcon : icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
