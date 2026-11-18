// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دمي';

  @override
  String get home => 'الرئيسية';

  @override
  String get phoneLogin => 'تسجيل الدخول';

  @override
  String get completeProfile => 'إكمال الملف الشخصي';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get bloodRequest => 'طلب تبرع بالدم';

  @override
  String get placeholder => 'قريباً';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get empty => 'لا توجد بيانات';
}
