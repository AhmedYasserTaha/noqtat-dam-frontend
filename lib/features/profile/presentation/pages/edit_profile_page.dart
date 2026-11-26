import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/egypt_locations.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/widgets/blood_type_selector.dart';
import '../../../../core/widgets/egypt_location_fields.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _bloodType;
  String? _governorateId;
  String? _districtId;
  EgyptLocation? _initialGovernorate;
  EgyptLocation? _initialDistrict;
  bool _isAvailable = true;
  bool _saving = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    final profile = cubit.state.profile;
    if (profile != null) {
      _applyProfile(profile);
    } else {
      cubit.load(reuseExisting: true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _applyProfile(UserProfile profile) {
    _prefilled = true;
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _bloodType = profile.bloodType;
    _governorateId = profile.governorateId;
    _districtId = profile.districtId;
    _isAvailable = profile.isAvailable;
    final governorateId = profile.governorateId;
    if (governorateId != null) {
      _initialGovernorate = EgyptLocation(
        id: governorateId,
        arabicName: profile.governorate?.ar ?? governorateId,
        englishName: profile.governorate?.en ?? governorateId,
      );
    }
    final districtId = profile.districtId;
    if (districtId != null) {
      _initialDistrict = EgyptLocation(
        id: districtId,
        arabicName: profile.district?.ar ?? districtId,
        englishName: profile.district?.en ?? districtId,
      );
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) {
      _snack(l10n.fieldRequired);
      return;
    }
    if (_bloodType == null) {
      _snack(l10n.chooseBloodType);
      return;
    }
    if (_governorateId == null) {
      _snack(l10n.errNeedGovernorate);
      return;
    }
    setState(() => _saving = true);
    final cubit = context.read<ProfileCubit>();
    final ok = await cubit.update(
      ProfileUpdate(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        bloodType: _bloodType,
        governorateId: _governorateId,
        districtId: _districtId,
        isAvailable: _isAvailable,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      _snack(l10n.profileSaved);
      context.pop();
      return;
    }
    final failure = cubit.state.actionFailure;
    _snack(failure == null ? l10n.errGeneric : failureMessage(l10n, failure));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) => !_prefilled && current.profile != null,
      listener: (context, state) {
        final profile = state.profile;
        if (profile == null) return;
        setState(() => _applyProfile(profile));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.editProfileTitle)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        enabled: !_saving,
                        validator: (value) => value?.trim().isEmpty ?? true
                            ? l10n.fieldRequired
                            : null,
                        decoration: InputDecoration(labelText: l10n.fullName),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        enabled: !_saving,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        validator: (value) => value?.trim().isEmpty ?? true
                            ? l10n.fieldRequired
                            : null,
                        decoration: InputDecoration(
                          labelText: l10n.mobileNumber,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.yourBloodType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      BloodTypeSelector(
                        value: _bloodType,
                        onChanged: (value) => setState(() => _bloodType = value),
                      ),
                      const SizedBox(height: 20),
                      EgyptLocationFields(
                        initialGovernorate: _initialGovernorate,
                        initialDistrict: _initialDistrict,
                        onChanged: (governorate, district) => setState(() {
                          _governorateId = governorate?.id;
                          _districtId = district?.id;
                        }),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        value: _isAvailable,
                        title: Text(
                          _isAvailable
                              ? l10n.markedAvailable
                              : l10n.unavailableNow,
                        ),
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _isAvailable = value),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: l10n.saveChanges,
                        onPressed: _saving ? null : _save,
                      ),
                      if (_saving) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.loading),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
