import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF1F1D1A);
  static const background = Color(0xFFFAF8F5);
  static const surface = Color(0xFFFFFFFF);
  static const subtle = Color(0xFFF3EFEA);
  static const border = Color(0xFFE7E2DA);
  static const muted = Color(0xFF78716C);
  static const red = Color(0xFFB91C1C);
  static const redOnDark = Color(0xFFDC2626);
  static const success = Color(0xFF15803D);
  static const warning = Color(0xFFB45309);
  static const info = Color(0xFF0369A1);
  static const redGradient = LinearGradient(
    colors: [Color(0xFFB91C1C), Color(0xFF991B1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract final class AppRadii {
  static const input = 14.0;
  static const button = 12.0;
  static const card = 16.0;
  static const hero = 22.0;
}
