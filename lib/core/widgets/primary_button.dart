import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppColors.redGradient,
        color: onPressed == null ? AppColors.border : null,
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(label),
      ),
    ),
  );
}

class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: OutlinedButton(onPressed: onPressed, child: Text(label)),
  );
}
