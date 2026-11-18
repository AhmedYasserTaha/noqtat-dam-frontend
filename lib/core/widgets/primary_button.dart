import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: ElevatedButton(onPressed: onPressed, child: Text(label)),
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
