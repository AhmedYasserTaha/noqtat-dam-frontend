import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/blood_types.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/egypt_location_fields.dart';
import '../../../../core/utils/egypt_locations.dart';
import '../../../../core/widgets/preview_ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../hospitals/presentation/widgets/hospital_field.dart';
import '../../domain/entities/blood_request.dart';
import '../cubit/blood_request_cubit.dart';

class BloodRequestPage extends StatefulWidget {
  const BloodRequestPage({
    super.key,
    this.embedded = false,
    this.initialRequest,
  });
  final BloodRequest? initialRequest;

  /// True when shown inside the create screen's tabs, which own the app bar.
  final bool embedded;
  @override
  State<BloodRequestPage> createState() => _BloodRequestPageState();
}

class _BloodRequestPageState extends State<BloodRequestPage> {
  final _hospital = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  String _bloodType = 'O-';
  int _bags = 3;
  int _urgency = 0;
  String? _governorate, _district, _governorateId, _districtId;
  bool _multipleDistricts = false;
  int? _hospitalId;
  DateTime? _deadline;
  bool _finished = false;
  EgyptLocation? _initialGovernorate, _initialDistrict;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRequest;
    if (r == null) return;
    _hospital.text = r.hospitalName;
    _phone.text = r.contactPhone ?? '';
    _notes.text = r.notes ?? '';
    _bloodType = r.bloodType;
    _bags = r.bagsNeeded;
    _urgency = r.urgency.index;
    _deadline = r.deadline?.toLocal();
    _hospitalId = r.hospitalId;
    _hospital.addListener(() {
      if (_hospitalId == r.hospitalId && _hospital.text != r.hospitalName) {
        _hospitalId = null;
      }
    });
    _governorateId = r.governorateId;
    _districtId = r.districtId;
    _governorate = r.governorate?.ar;
    _district = r.district?.ar;
    if (_governorateId != null)
      _initialGovernorate = EgyptLocation(
        id: _governorateId!,
        arabicName: r.governorate?.ar ?? '',
        englishName: r.governorate?.en ?? '',
      );
    if (_districtId != null)
      _initialDistrict = EgyptLocation(
        id: _districtId!,
        parentId: _governorateId,
        arabicName: r.district?.ar ?? '',
        englishName: r.district?.en ?? '',
      );
  }

  @override
  void dispose() {
    _hospital.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  String _dateLabel(BuildContext context) => _deadline == null
      ? AppLocalizations.of(context)!.chooseDeadline
      : DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
            .add_jm()
            .format(_deadline!);

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? now),
    );
    if (!mounted || time == null) return;
    setState(
      () => _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _review() async {
    FocusScope.of(context).unfocus();
    final t = AppLocalizations.of(context)!;
    if (_multipleDistricts) {
      _snack(t.multipleDistrictsPending);
      return;
    }
    final existing = widget.initialRequest;
    if (existing != null &&
        (existing.status != RequestStatus.open ||
            (existing.deadline?.isBefore(DateTime.now()) ?? false))) {
      _snack(t.requestClosedForEditing);
      return;
    }
    final missing =
        _hospital.text.trim().isEmpty ||
        _governorateId == null ||
        _phone.text.trim().isEmpty;
    if (missing) {
      _snack(t.requestMissingFields);
      return;
    }
    if (_urgency == 2 && _deadline == null) {
      _snack(t.requestNeedsDeadline);
      return;
    }
    if (_urgency == 2 && !_deadline!.isAfter(DateTime.now())) {
      _snack(t.requestFutureDeadline);
      return;
    }
    final urgency = [
      t.urgencyCritical,
      t.urgencyDay,
      t.urgencyScheduled,
    ][_urgency];
    final published = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * .85,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          children: [
            Text(
              t.reviewRequestTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              t.requestPreviewNotice,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 16),
            PreviewCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _bloodType,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_bags ${t.bagsNeededLabel}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              urgency,
                              style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PreviewRow(
                    label: t.hospitalNameLabel,
                    value: _hospital.text.isEmpty
                        ? t.previewNotSpecified
                        : _hospital.text,
                    icon: AppIcons.locationPin,
                  ),
                  PreviewRow(
                    label: t.governorateLabel,
                    value: _governorate ?? t.previewNotSpecified,
                    icon: AppIcons.map,
                  ),
                  PreviewRow(
                    label: t.districtLabel,
                    value: _district ?? t.previewNotSpecified,
                    icon: AppIcons.locationPin,
                  ),
                  PreviewRow(
                    label: t.deadlineLabel,
                    value: _deadline == null
                        ? t.previewNotSpecified
                        : _dateLabel(context),
                    icon: AppIcons.clock,
                  ),
                  PreviewRow(
                    label: t.contactPhoneLabel,
                    value: _phone.text.isEmpty
                        ? t.previewNotSpecified
                        : _phone.text,
                    icon: AppIcons.userOutline,
                  ),
                  PreviewRow(
                    label: t.requestNotesLabel,
                    value: _notes.text.isEmpty
                        ? t.previewNotSpecified
                        : _notes.text,
                    icon: AppIcons.comment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(sheetContext, true),
              child: Text(
                widget.initialRequest == null
                    ? t.confirmRequestPreview
                    : t.saveChanges,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(sheetContext, false),
              child: Text(t.editRequestPreview),
            ),
          ],
        ),
      ),
    );
    if (!mounted || published != true) return;
    context.read<BloodRequestCubit>().submit(
      BloodRequestDraft(
        bloodType: _bloodType,
        bagsNeeded: _bags,
        hospitalName: _hospital.text.trim(),
        hospitalId: _hospitalId,
        governorateId: _governorateId!,
        districtId: _districtId,
        urgency: Urgency.values[_urgency],
        contactPhone: _phone.text.trim(),
        deadline: _urgency == 2 ? _deadline : null,
        notes: _notes.text,
      ),
      requestId: widget.initialRequest?.id,
      original: widget.initialRequest,
    );
  }

  void _snack(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    ),
  );

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<BloodRequestCubit, BloodRequestState>(
        listener: (context, state) {
          if (state.status == CreateStatus.success) {
            if (widget.initialRequest != null) {
              Navigator.pop(context, state.request);
              return;
            }
            setState(() => _finished = true);
          } else if (state.status == CreateStatus.failure &&
              state.failure != null) {
            _snack(
              failureMessage(AppLocalizations.of(context)!, state.failure!),
            );
          }
        },
        builder: (context, state) =>
            _scaffold(context, state.status == CreateStatus.submitting),
      );

  Widget _scaffold(BuildContext context, bool submitting) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(
                widget.initialRequest == null
                    ? t.createRequestAction
                    : t.editBloodRequest,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              leading: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/'),
                icon: const AppIcon(
                  AppIcons.arrowBackRtl,
                  color: AppColors.ink,
                ),
              ),
            ),
      body: _finished
          ? _success(t)
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Text(
                      widget.initialRequest == null
                          ? t.createRequestSubtitle
                          : t.editBloodRequestHint,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.8,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    PreviewCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label(t.requiredBloodType),
                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.65,
                            children: [
                              for (final type in BloodTypes.values)
                                OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _bloodType = type),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: _bloodType == type
                                        ? AppColors.red
                                        : Colors.white,
                                    foregroundColor: _bloodType == type
                                        ? Colors.white
                                        : AppColors.ink,
                                    side: BorderSide(
                                      color: _bloodType == type
                                          ? AppColors.red
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    type,
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.numberOfBags,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: t.decreaseBags,
                                onPressed:
                                    _bags >
                                        (widget.initialRequest?.bagsCollected ??
                                                1)
                                            .clamp(1, 20)
                                    ? () => setState(() => _bags--)
                                    : null,
                                icon: const Text(
                                  '−',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '$_bags',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: t.increaseBags,
                                onPressed: _bags < 20
                                    ? () => setState(() => _bags++)
                                    : null,
                                icon: const AppIcon(
                                  AppIcons.plus,
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PreviewCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          EgyptLocationFields(
                            allowAllDistricts: true,
                            onDistrictsChanged: (districts) {
                              setState(() {
                                _multipleDistricts = districts.length > 1;
                              });
                            },
                            initialGovernorate: _initialGovernorate,
                            initialDistrict: _initialDistrict,
                            onChanged: (governorate, district) {
                              final language = Localizations.localeOf(context)
                                  .languageCode;
                              _governorate = governorate?.name(language);
                              _district = district?.name(language);
                              setState(() {
                                if (_governorateId != governorate?.id)
                                  _hospitalId = null;
                                _governorateId = governorate?.id;
                                _districtId = district?.id;
                              });
                            },
                          ),
                          const SizedBox(height: 18),
                          _label(t.hospitalNameLabel),
                          HospitalField(
                            governorateId: _governorateId,
                            districtId: _districtId,
                            controller: _hospital,
                            onSelected: (hospital) =>
                                _hospitalId = hospital?.id,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PreviewCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label(t.urgencyLabel),
                          for (final (index, title, subtitle) in [
                            (0, t.urgencyCritical, t.urgencyCriticalHint),
                            (1, t.urgencyDay, t.urgencyDayHint),
                            (2, t.urgencyScheduled, t.urgencyScheduledHint),
                          ])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: OutlinedButton(
                                onPressed: () =>
                                    setState(() => _urgency = index),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(12),
                                  foregroundColor: AppColors.ink,
                                  side: BorderSide(
                                    color: _urgency == index
                                        ? AppColors.red
                                        : AppColors.border,
                                    width: _urgency == index ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    AppIcon(
                                      _urgency == index
                                          ? AppIcons.check
                                          : AppIcons.clock,
                                      color: _urgency == index
                                          ? AppColors.red
                                          : AppColors.muted,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            subtitle,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          _label(t.deadlineLabel),
                          OutlinedButton(
                            onPressed: _chooseDate,
                            child: Row(
                              children: [
                                const AppIcon(
                                  AppIcons.clock,
                                  color: AppColors.muted,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _dateLabel(context),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PreviewCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label(t.contactPhoneLabel),
                          TextField(
                            key: const ValueKey('request-phone'),
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              hintText: '010 1234 5678',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.contactPreviewHint,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.8,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _label(t.requestNotesLabel),
                          TextField(
                            key: const ValueKey('request-notes'),
                            controller: _notes,
                            minLines: 3,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: t.requestNotesHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _finished
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 472),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: submitting ? null : _review,
                      child: Text(
                        submitting ? t.loading : t.reviewRequestTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _success(AppLocalizations t) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: AppIcon(AppIcons.check, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              t.requestPreviewDone,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              t.requestNotPublished,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.9,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/requests'),
                child: Text(t.viewMyRequests),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/'),
              child: Text(t.backToHome),
            ),
          ],
        ),
      ),
    ),
  );
}
