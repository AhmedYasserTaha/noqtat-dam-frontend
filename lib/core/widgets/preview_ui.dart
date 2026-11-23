import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class PreviewCard extends StatelessWidget {
  const PreviewCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(20),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}

class PreviewPage extends StatelessWidget {
  const PreviewPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final String title, subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    ),
  );
}

class PreviewRow extends StatelessWidget {
  const PreviewRow({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    this.onTap,
    this.trailing,
  });
  final String label, icon;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: AppIcon(icon, color: AppColors.ink, size: 21),
    title: Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
    subtitle: value == null
        ? null
        : Text(
            value!,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
    trailing:
        trailing ??
        (onTap == null
            ? null
            : const AppIcon(
                AppIcons.arrowBackRtl,
                color: AppColors.muted,
                size: 17,
              )),
    onTap: onTap,
  );
}

Future<void> showPreviewMessage(
  BuildContext context,
  String title,
  String message,
) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  backgroundColor: Colors.white,
  showDragHandle: true,
  builder: (context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.9,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    ),
  ),
);
