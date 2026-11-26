import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../di/injection.dart';
import '../network/locations_api.dart';
import '../utils/egypt_locations.dart';

class EgyptLocationFields extends StatefulWidget {
  const EgyptLocationFields({
    super.key,
    this.onChanged,
    this.initialGovernorate,
    this.initialDistrict,
    this.allowAllDistricts = false,
  });
  final EgyptLocation? initialGovernorate, initialDistrict;
  final bool allowAllDistricts;
  final void Function(EgyptLocation? governorate, EgyptLocation? district)?
  onChanged;

  @override
  State<EgyptLocationFields> createState() => _EgyptLocationFieldsState();
}

class _EgyptLocationFieldsState extends State<EgyptLocationFields> {
  late final LocationsApi _locations;
  late Future<List<EgyptLocation>> _data;
  Future<List<EgyptLocation>>? _districts;
  EgyptLocation? _governorate;
  EgyptLocation? _district;

  @override
  void initState() {
    super.initState();
    _locations = getIt<LocationsApi>();
    _data = _locations.governorates();
    _governorate = widget.initialGovernorate;
    _district = widget.initialDistrict;
    if (_governorate != null)
      _districts = _locations.districts(_governorate!.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FutureBuilder<List<EgyptLocation>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return TextButton(
            onPressed: () => setState(() => _data = _locations.governorates()),
            child: Text(t.retry),
          );
        }
        final data = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              key: const ValueKey('governorate'),
              label: t.governorateLabel,
              hint: data == null ? t.loadingLocations : t.selectGovernorate,
              value: _governorate,
              onTap: data == null
                  ? null
                  : () async {
                      final selected = await _pick(
                        context,
                        t.selectGovernorate,
                        data,
                      );
                      if (!mounted ||
                          selected == null ||
                          selected.id == _governorate?.id) {
                        return;
                      }
                      setState(() {
                        _governorate = selected;
                        _district = null;
                        _districts = _locations.districts(selected.id);
                      });
                      widget.onChanged?.call(_governorate, null);
                    },
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<EgyptLocation>>(
              future: _districts,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return TextButton(
                    onPressed: () => setState(() {
                      _districts = _locations.districts(_governorate!.id);
                    }),
                    child: Text(t.retry),
                  );
                }
                final items = snapshot.connectionState == ConnectionState.done
                    ? snapshot.data
                    : null;
                return _field(
                  key: ValueKey('district-${_governorate?.id}'),
                  label: t.districtLabel,
                  hint: _governorate == null
                      ? t.chooseGovernorateFirst
                      : items == null
                      ? t.loadingLocations
                      : widget.allowAllDistricts && _district == null
                      ? t.allGovernorateDistricts
                      : t.selectDistrict,
                  value: _district,
                  onTap: items == null || _governorate == null
                      ? null
                      : () async {
                          final governorateId = _governorate!.id;
                          final selected = await _pick(
                            context,
                            t.selectDistrict,
                            items,
                          );
                          if (!mounted ||
                              selected == null ||
                              _governorate?.id != governorateId) {
                            return;
                          }
                          setState(() => _district = selected);
                          widget.onChanged?.call(_governorate, _district);
                        },
                );
              },
            ),
            if (widget.allowAllDistricts && _governorate != null) ...[
              const SizedBox(height: 6),
              Text(
                t.requestAreaNotice,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  height: 1.6,
                ),
              ),
              if (_district != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    key: const Key('clear-request-district'),
                    onPressed: () {
                      setState(() => _district = null);
                      widget.onChanged?.call(_governorate, null);
                    },
                    child: Text(t.allGovernorateDistricts),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _field({
    required Key key,
    required String label,
    required String hint,
    required EgyptLocation? value,
    required VoidCallback? onTap,
  }) {
    final language = Localizations.localeOf(context).languageCode;
    return FormField<EgyptLocation>(
      key: key,
      initialValue: value,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF403838),
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            button: true,
            enabled: onTap != null,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  enabled: onTap != null,
                  errorText: value == null ? field.errorText : null,
                  suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                child: Text(
                  value?.name(language) ?? hint,
                  style: TextStyle(
                    fontSize: 14,
                    color: value == null ? AppColors.muted : AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<EgyptLocation?> _pick(
  BuildContext context,
  String title,
  List<EgyptLocation> locations,
) => showModalBottomSheet<EgyptLocation>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (_) => _LocationPicker(title: title, locations: locations),
);

class _LocationPicker extends StatefulWidget {
  const _LocationPicker({required this.title, required this.locations});
  final String title;
  final List<EgyptLocation> locations;
  @override
  State<_LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<_LocationPicker> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode;
    final matches =
        widget.locations
            .where(
              (item) => normalizeLocationSearch(
                '${item.arabicName} ${item.englishName}',
              ).contains(_query),
            )
            .toList()
          ..sort((a, b) => a.name(language).compareTo(b.name(language)));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
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
                  hintText: t.searchLocations,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? Center(child: Text(t.noLocationsFound))
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          matches[index].name(language),
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => Navigator.pop(context, matches[index]),
                      ),
                    ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Open Admin Data · CC BY 4.0',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
