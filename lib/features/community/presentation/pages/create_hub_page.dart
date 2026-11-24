import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../l10n/app_localizations.dart';

/// First step of creating something: a normal post or a blood request.
class CreateHubPage extends StatelessWidget {
  const CreateHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.createChoiceTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 512),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Choice(
                key: const Key('create-choice-post'),
                icon: AppIcons.comment,
                title: t.createPostOption,
                hint: t.createPostHint,
                onTap: () => context.pushReplacement('/new-post'),
              ),
              const SizedBox(height: 12),
              _Choice(
                key: const Key('create-choice-request'),
                icon: AppIcons.bloodDropFilled,
                title: t.createRequestOption,
                hint: t.createRequestHint,
                onTap: () => context.pushReplacement('/blood-request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
  });
  final String icon, title, hint;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AppIcon(icon, color: AppColors.red, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hint,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
