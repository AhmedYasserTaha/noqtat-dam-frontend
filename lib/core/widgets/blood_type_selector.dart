import 'package:flutter/material.dart';

import '../constants/blood_types.dart';

class BloodTypeChip extends StatelessWidget {
  const BloodTypeChip({
    super.key,
    required this.type,
    this.selected = false,
    this.onSelected,
  });
  final String type;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: ChoiceChip(
      label: Text(type),
      selected: selected,
      onSelected: onSelected,
    ),
  );
}

class BloodTypeSelector extends StatelessWidget {
  const BloodTypeSelector({super.key, this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.6,
    children: [
      for (final type in BloodTypes.values)
        Center(
          child: BloodTypeChip(
            type: type,
            selected: type == value,
            onSelected: (_) => onChanged(type),
          ),
        ),
    ],
  );
}
