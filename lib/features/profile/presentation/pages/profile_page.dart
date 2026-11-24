import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

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
  bool _loadingHistory = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().load();
  }

  Future<void> _edit(UserProfile profile) async {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<ProfileCubit>();
    var name = profile.name;
    var phone = profile.phone;
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
                child: Text(t.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null || result.$1.trim().isEmpty) return;
    final ok = await cubit.update(
      ProfileUpdate(name: result.$1.trim(), phone: result.$2.trim()),
    );
    if (!mounted) return;
    _result(ok, t.profileSaved);
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

  Future<void> _openHistory() async {
    if (_loadingHistory) return;
    setState(() => _loadingHistory = true);
    final cubit = context.read<ProfileCubit>();
    final loaded = await cubit.loadHistory();
    if (!mounted) return;
    setState(() => _loadingHistory = false);
    if (!loaded) {
      _result(false, '');
      return;
    }
    _history(cubit.state.donations);
  }

  void _history(List<DonationRecord> donations) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final preview = kDebugMode && donations.isEmpty;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final records = preview
        ? [
            DonationRecord(
              requestId: 101,
              donatedAt: DateTime.now().subtract(const Duration(days: 30)),
              bloodType: 'O+',
              hospitalName: arabic
                  ? 'مستشفى المنصورة الجامعي'
                  : 'Mansoura University Hospital',
            ),
            DonationRecord(
              requestId: 102,
              donatedAt: DateTime.now().subtract(const Duration(days: 150)),
              bloodType: 'O+',
              hospitalName: arabic
                  ? 'مستشفى طلخا العام'
                  : 'Talkha General Hospital',
            ),
            DonationRecord(
              requestId: 103,
              donatedAt: DateTime.now().subtract(const Duration(days: 270)),
              bloodType: 'O+',
              hospitalName: arabic ? 'مستشفى السلام' : 'Al Salam Hospital',
            ),
          ]
        : donations;
    final body = records.isEmpty
        ? t.noDonationsRecorded
        : '${preview ? '${t.staticAccountPreview}\n\n' : ''}'
              '${records.map((d) => '${DateFormat.yMMMd(locale).format(d.donatedAt.toLocal())} · ${d.bloodType}\n${d.hospitalName}').join('\n\n')}\n\n${t.selfReportedNote}';
    showPreviewMessage(context, t.donationHistoryTitle, body);
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
                  onPressed: () => _edit(profile),
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
              PreviewRow(
                label: t.donationHistoryTitle,
                icon: AppIcons.bloodDropFilled,
                value: '${profile.donationsCount} · ${t.selfReportedTag}',
                onTap: _loadingHistory ? null : _openHistory,
                trailing: _loadingHistory
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
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
