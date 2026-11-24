import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/egypt_locations.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/hospital.dart';
import '../cubit/hospital_list_cubit.dart';

/// Hospital input for the create-request form. When the reviewed directory has
/// hospitals for the chosen governorate the user picks one (the request then
/// carries its id). Otherwise, or by choice, the user types the name.
/// [controller] always holds the hospital name that will be sent.
class HospitalField extends StatefulWidget {
  const HospitalField({
    super.key,
    required this.governorateId,
    required this.controller,
    required this.onSelected,
  });
  final String? governorateId;
  final TextEditingController controller;
  final ValueChanged<Hospital?> onSelected;

  @override
  State<HospitalField> createState() => _HospitalFieldState();
}

class _HospitalFieldState extends State<HospitalField> {
  late final HospitalListCubit _cubit = getIt<HospitalListCubit>();
  Hospital? _selected;
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _cubit.load(widget.governorateId);
  }

  @override
  void didUpdateWidget(HospitalField old) {
    super.didUpdateWidget(old);
    if (old.governorateId == widget.governorateId) return;
    if (_selected != null) {
      widget.controller.clear();
      widget.onSelected(null);
    }
    _selected = null;
    _typing = false;
    _cubit.load(widget.governorateId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _choose(List<Hospital> hospitals) async {
    final result = await showModalBottomSheet<_HospitalChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _HospitalPicker(hospitals: hospitals),
    );
    if (!mounted || result == null) return;
    if (result.other) {
      setState(() {
        _selected = null;
        _typing = true;
      });
      widget.controller.clear();
      widget.onSelected(null);
      return;
    }
    setState(() => _selected = result.hospital);
    widget.controller.text = result.hospital!.name;
    widget.onSelected(result.hospital);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<HospitalListCubit, HospitalListState>(
      bloc: _cubit,
      builder: (context, state) {
        final hospitals = state.hospitals;
        final listed =
            state.status == HospitalListStatus.loaded && hospitals.isNotEmpty;
        if (listed && !_typing) {
          return Semantics(
            button: true,
            child: InkWell(
              key: const ValueKey('request-hospital-picker'),
              onTap: () => _choose(hospitals),
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                child: Text(
                  _selected?.name ?? t.chooseHospital,
                  style: TextStyle(
                    fontSize: 14,
                    color: _selected == null ? AppColors.muted : AppColors.ink,
                  ),
                ),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const ValueKey('request-hospital'),
              controller: widget.controller,
              decoration: InputDecoration(hintText: t.hospitalNameHint),
            ),
            if (listed)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () {
                    widget.controller.clear();
                    setState(() => _typing = false);
                  },
                  child: Text(t.chooseFromHospitalList),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HospitalChoice {
  const _HospitalChoice.pick(Hospital this.hospital) : other = false;
  const _HospitalChoice.other() : hospital = null, other = true;
  final Hospital? hospital;
  final bool other;
}

class _HospitalPicker extends StatefulWidget {
  const _HospitalPicker({required this.hospitals});
  final List<Hospital> hospitals;
  @override
  State<_HospitalPicker> createState() => _HospitalPickerState();
}

class _HospitalPickerState extends State<_HospitalPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final matches = widget.hospitals
        .where((h) => normalizeLocationSearch(h.name).contains(_query))
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.chooseHospital,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: t.closeLocations,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) =>
                    setState(() => _query = normalizeLocationSearch(value)),
                decoration: InputDecoration(
                  hintText: t.searchHospitals,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? Center(child: Text(t.noHospitalsFound))
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          matches[index].name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => Navigator.pop(
                          context,
                          _HospitalChoice.pick(matches[index]),
                        ),
                      ),
                    ),
            ),
            ListTile(
              key: const ValueKey('hospital-not-listed'),
              leading: const Icon(Icons.edit_outlined),
              title: Text(t.hospitalNotListed),
              onTap: () =>
                  Navigator.pop(context, const _HospitalChoice.other()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                t.hospitalDataCredit,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
