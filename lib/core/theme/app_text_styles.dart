import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const body = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 13,
    height: 1.5,
    color: AppColors.ink,
    fontWeight: FontWeight.w400,
  );
  static const title = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    height: 1.4,
    color: AppColors.ink,
    fontWeight: FontWeight.w700,
  );
  static const label = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static const hero = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 26,
    fontWeight: FontWeight.w900,
  );
}
