import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../app.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/preview_ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().load();
  }

  void _result(bool ok, String success) {
    final t = AppLocalizations.of(context)!;
    final f = context.read<ProfileCubit>().state.actionFailure;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok || f == null ? success : failureMessage(t, f))),
    );
  }

  Future<void> _toggle(ProfileUpdate update) async {
    final ok = await context.read<ProfileCubit>().update(update);
    if (!mounted || ok) return;
    _result(false, '');
  }

  Future<void> _pickLastDonation(UserProfile profile) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: profile.lastDonationAt?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await _toggle(ProfileUpdate(lastDonationAt: picked.toUtc()));
    }
  }

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final locale = Localizations.localeOf(context).toString();
    final state = context.watch<ProfileCubit>().state;
    final profile = state.profile;
    if (profile == null) {
      return Center(
        child: state.status == ProfileStatus.failure
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(failureMessage(t, state.failure!)),
                  TextButton(
                    onPressed: () => context.read<ProfileCubit>().load(),
                    child: Text(t.retry),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      );
    }
    final last = profile.lastDonationAt;
    return PreviewPage(
      title: t.myAccountTab,
      subtitle: t.accountSubtitle,
      children: [
        PreviewCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6EEEB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: AppIcon(
                        AppIcons.userFilled,
                        color: AppColors.red,
                        size: 23,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          t.memberSince(
                            DateFormat.yMMM(locale)
                                .format(profile.createdAt.toLocal()),
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile.bloodType,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: () => context.push('/edit-profile'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    textStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(t.editProfileTitle),
                ),
              ),
            ],
          ),
        ),
        _section(t.personalInfoTitle),
        PreviewCard(
          child: Column(
            children: [
              PreviewRow(
                label: t.mobileNumber,
                value: profile.phone,
                icon: AppIcons.userOutline,
              ),
              PreviewRow(
                label: t.governorateLabel,
                value: profile.governorate?.of(lang) ?? t.notSet,
                icon: AppIcons.locationPin,
              ),
              PreviewRow(
                label: t.districtLabel,
                value: profile.district?.of(lang) ?? t.notSet,
                icon: AppIcons.map,
              ),
              PreviewRow(
                label: t.postsTitle,
                icon: AppIcons.comment,
                onTap: () => context.push('/posts'),
              ),
            ],
          ),
        ),
        _section(t.donationInfoTitle),
        PreviewCard(
          child: Column(
            children: [
              PreviewRow(
                label: t.myDonationsTitle,
                icon: AppIcons.heart,
                onTap: () => context.push('/my-donations'),
              ),
              PreviewRow(
                label: t.yourBloodType,
                value: profile.bloodType,
                icon: AppIcons.bloodDropOutline,
              ),
              PreviewRow(
                label: t.lastDonationLabel,
                value: last == null
                    ? t.notSet
                    : '${DateFormat.yMMMd(locale).format(last.toLocal())} · ${t.selfReportedTag}',
                icon: AppIcons.clock,
                onTap: () => _pickLastDonation(profile),
              ),
              if (last != null)
                _DonationCountdownCard(
                  lastDonationAt: last,
                  lang: lang,
                ),
              PreviewRow(
                label: t.availabilityLabel,
                value: t.availabilityHint,
                icon: AppIcons.heart,
                trailing: Switch(
                  value: profile.isAvailable,
                  onChanged: (value) =>
                      _toggle(ProfileUpdate(isAvailable: value)),
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
                value: t.notificationsHint,
                icon: AppIcons.bell,
                trailing: Switch(
                  value: profile.notificationsEnabled,
                  onChanged: (value) =>
                      _toggle(ProfileUpdate(notificationsEnabled: value)),
                ),
              ),
              PreviewRow(
                label: t.languageLabel,
                value: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'العربية'
                    : 'English',
                icon: AppIcons.settings,
                onTap: () async {
                  final selected = await showModalBottomSheet<String>(
                    context: context,
                    showDragHandle: true,
                    useSafeArea: true,
                    builder: (sheetContext) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            t.languageLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        for (final option in const {
                          'ar': 'العربية',
                          'en': 'English',
                        }.entries)
                          ListTile(
                            title: Text(option.value),
                            trailing: lang == option.key
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.red,
                                  )
                                : null,
                            onTap: () =>
                                Navigator.pop(sheetContext, option.key),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                  if (!context.mounted || selected == null) return;
                  DamyApp.setLocale(context, Locale(selected));
                },
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
          onPressed: () => context.read<AuthCubit>().signOut(),
          child: Text(t.logoutAction),
        ),
        TextButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(t.deleteAccountTitle),
                content: Text(t.deleteAccountBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(t.keepAccountAction),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(t.deleteAccountConfirm),
                  ),
                ],
              ),
            );
            if (!context.mounted || confirmed != true) return;
            final cubit = context.read<ProfileCubit>();
            final auth = context.read<AuthCubit>();
            final ok = await cubit.deleteAccount();
            if (!context.mounted) return;
            if (ok) {
              await auth.signOut();
            } else {
              _result(false, '');
            }
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

class _DonationCountdownCard extends StatelessWidget {
  const _DonationCountdownCard({
    required this.lastDonationAt,
    required this.lang,
  });

  final DateTime lastDonationAt;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final nextDate = lastDonationAt.toLocal().add(const Duration(days: 60));
    final remaining = nextDate.difference(DateTime.now()).inDays;
    final clampedRemaining = remaining.clamp(0, 60);
    final elapsed = 60 - clampedRemaining;
    final eligible = remaining <= 0;
    final statusText = eligible
        ? (lang == 'ar' ? 'مؤهل للتبرع الآن' : 'Eligible to donate now')
        : (lang == 'ar'
            ? 'متبقي $clampedRemaining يوم (كل 60 يوم)'
            : '$clampedRemaining days left (60-day cycle)');
    final badgeText = eligible
        ? (lang == 'ar' ? 'جاهز' : 'Ready')
        : (lang == 'ar' ? '$elapsed / 60 يوم' : '$elapsed / 60d');
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: eligible ? const Color(0xFFF1F8F4) : const Color(0xFFFDF6F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: eligible ? const Color(0xFFC8E6D2) : const Color(0xFFF0D9D5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lang == 'ar' ? 'التبرع القادم' : 'Next donation',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: eligible ? const Color(0xFF1E8E4E) : AppColors.red,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            statusText,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: elapsed / 60,
            minHeight: 7,
            borderRadius: BorderRadius.circular(999),
            color: eligible ? const Color(0xFF1E8E4E) : AppColors.red,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
