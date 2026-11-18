import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.keyboardType,
    this.onChanged,
    this.obscureText = false,
  });
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(hintText: hint),
    ),
  );
}
