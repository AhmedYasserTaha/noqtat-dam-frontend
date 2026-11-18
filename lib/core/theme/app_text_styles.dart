import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const body = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    color: AppColors.ink,
    fontWeight: FontWeight.w400,
  );
  static const title = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 22,
    color: AppColors.ink,
    fontWeight: FontWeight.w700,
  );
  static const label = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const hero = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 32,
    fontWeight: FontWeight.w900,
  );
}
