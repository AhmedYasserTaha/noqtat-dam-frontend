import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/egypt_locations.dart';

class EgyptLocationFields extends StatefulWidget {
  const EgyptLocationFields({super.key, this.onChanged});
  final void Function(EgyptLocation? governorate, EgyptLocation? district)?
  onChanged;

  @override
  State<EgyptLocationFields> createState() => _EgyptLocationFieldsState();
}

class _EgyptLocationFieldsState extends State<EgyptLocationFields> {
  late Future<EgyptLocations> _data;
  EgyptLocation? _governorate;
  EgyptLocation? _district;

  @override
  void initState() {
    super.initState();
    _data = EgyptLocations.load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FutureBuilder<EgyptLocations>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return TextButton(
            onPressed: () => setState(() => _data = EgyptLocations.load()),
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
                        data.governorates,
                      );
                      if (!mounted ||
                          selected == null ||
                          selected.id == _governorate?.id) {
                        return;
                      }
                      setState(() {
                        _governorate = selected;
                        _district = null;
                      });
                      widget.onChanged?.call(_governorate, null);
                    },
            ),
            const SizedBox(height: 16),
            _field(
              key: ValueKey('district-${_governorate?.id}'),
              label: t.districtLabel,
              hint: _governorate == null
                  ? t.chooseGovernorateFirst
                  : t.selectDistrict,
              value: _district,
              onTap: data == null || _governorate == null
                  ? null
                  : () async {
                      final selected = await _pick(
                        context,
                        t.selectDistrict,
                        data.districtsOf(_governorate!.id),
                      );
                      if (!mounted || selected == null) return;
                      setState(() => _district = selected);
                      widget.onChanged?.call(_governorate, _district);
                    },
            ),
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
    final t = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode;
    return FormField<EgyptLocation>(
      key: key,
      initialValue: value,
      validator: (_) => value == null ? t.requiredField : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
