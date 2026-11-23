import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/preview_ui.dart';
import '../../../../l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _available = true;
  bool _notifications = true;
  String? _name;
  String _phone = '010 1234 5678';

  Future<void> _edit() async {
    final t = AppLocalizations.of(context)!;
    var name = _name ?? t.demoDonorName;
    var phone = _phone;
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.editProfileTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.localEditNotice,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: name,
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: t.fullName),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: phone,
                onChanged: (value) => phone = value,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(labelText: t.mobileNumber),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext, (name, phone)),
                child: Text(t.savePreview),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && result != null) {
      setState(() {
        _name = result.$1;
        _phone = result.$2;
      });
    }
  }

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return PreviewPage(
      title: t.myAccountTab,
      subtitle: t.staticAccountPreview,
      children: [
        PreviewCard(
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EEEB),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: AppIcon(
                    AppIcons.userFilled,
                    color: AppColors.red,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _name ?? t.demoDonorName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                t.demoMemberSince,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'O-',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _edit,
                  child: Text(t.editProfileTitle),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final (number, label) in [
              ('3', t.donationsStat),
              ('2', t.requestsStat),
              ('4', t.monthsSinceStat),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: PreviewCard(
                    child: Column(
                      children: [
                        Text(
                          number,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: AppColors.red,
                          ),
                        ),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        _section(t.personalInfoTitle),
        PreviewCard(
          child: Column(
            children: [
              PreviewRow(
                label: t.mobileNumber,
                value: _phone,
                icon: AppIcons.userOutline,
              ),
              PreviewRow(
                label: t.emailLabel,
                value: 'donor@example.com',
                icon: AppIcons.comment,
              ),
              PreviewRow(
                label: t.governorateLabel,
                value: t.demoGovernorate,
                icon: AppIcons.locationPin,
              ),
              PreviewRow(
                label: t.districtLabel,
                value: t.mansouraCity,
                icon: AppIcons.map,
              ),
              PreviewRow(
                label: t.birthDateLabel,
                value: '12/04/1998',
                icon: AppIcons.clock,
              ),
              PreviewRow(
                label: t.genderLabel,
                value: t.maleLabel,
                icon: AppIcons.userOutline,
              ),
            ],
          ),
        ),
        _section(t.donationInfoTitle),
        PreviewCard(
          child: Column(
            children: [
              PreviewRow(
                label: t.yourBloodType,
                value: 'O-',
                icon: AppIcons.bloodDropOutline,
              ),
              PreviewRow(
                label: t.lastDonationLabel,
                value: '23/07/2026',
                icon: AppIcons.clock,
              ),
              PreviewRow(
                label: t.availabilityLabel,
                value: t.localEditNotice,
                icon: AppIcons.heart,
                trailing: Switch(
                  value: _available,
                  onChanged: (value) => setState(() => _available = value),
                ),
              ),
              PreviewRow(
                label: t.donationHistoryTitle,
                icon: AppIcons.bloodDropFilled,
                onTap: () => showPreviewMessage(
                  context,
                  t.donationHistoryTitle,
                  t.demoDonationHistory,
                ),
              ),
            ],
          ),
        ),
        _section(t.settingsTitle),
        PreviewCard(
          child: Column(
            children: [
              PreviewRow(
                label: t.notificationsTitle,
                value: t.localEditNotice,
                icon: AppIcons.bell,
                trailing: Switch(
                  value: _notifications,
                  onChanged: (value) => setState(() => _notifications = value),
                ),
              ),
              PreviewRow(
                label: t.languageLabel,
                value: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'العربية'
                    : 'English',
                icon: AppIcons.settings,
                onTap: () => showPreviewMessage(
                  context,
                  t.languageLabel,
                  t.languagePreviewBody,
                ),
              ),
            ],
          ),
        ),
        _section(t.supportAndLegalTitle),
        PreviewCard(
          child: Column(
            children: [
              PreviewRow(
                label: t.privacyTitle,
                icon: AppIcons.userOutline,
                onTap: () => context.push('/privacy'),
              ),
              PreviewRow(
                label: t.termsTitle,
                icon: AppIcons.check,
                onTap: () => context.push('/terms'),
              ),
              PreviewRow(
                label: t.helpTitle,
                icon: AppIcons.comment,
                onTap: () => context.push('/help'),
              ),
              PreviewRow(
                label: t.aboutTitle,
                icon: AppIcons.bloodDropOutline,
                onTap: () => context.push('/about'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => context.go('/auth'),
          child: Text(t.logoutAction),
        ),
        TextButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(t.deleteAccountTitle),
                content: Text(t.deletePreviewBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(t.keepAccountAction),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(t.confirmPreviewAction),
                  ),
                ],
              ),
            );
            if (!context.mounted || confirmed != true) return;
            await showPreviewMessage(
              context,
              t.deleteAccountTitle,
              t.noAccountDeleted,
            );
          },
          child: Text(
            t.deleteAccountTitle,
            style: const TextStyle(color: AppColors.red),
          ),
        ),
        Center(
          child: Text(
            '${t.authBrand} · 1.0.0',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}
