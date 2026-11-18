import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'دمي'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @phoneLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get phoneLogin;

  /// No description provided for @completeProfile.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الملف الشخصي'**
  String get completeProfile;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @bloodRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب تبرع بالدم'**
  String get bloodRequest;

  /// No description provided for @placeholder.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get placeholder;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @empty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get empty;

  /// No description provided for @authBrand.
  ///
  /// In ar, this message translates to:
  /// **'دم الخير'**
  String get authBrand;

  /// No description provided for @authTagline.
  ///
  /// In ar, this message translates to:
  /// **'كل قطرة بتفرق'**
  String get authTagline;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بيك تاني'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة السر؟'**
  String get forgotPassword;

  /// No description provided for @mobileNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get mobileNumber;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر'**
  String get passwordLabel;

  /// No description provided for @loginAction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginAction;

  /// No description provided for @continueGuest.
  ///
  /// In ar, this message translates to:
  /// **'كمّل كزائر'**
  String get continueGuest;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'معندكش حساب؟'**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دلوقتي'**
  String get registerNow;

  /// No description provided for @haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'عندك حساب؟'**
  String get haveAccount;

  /// No description provided for @stepOneOfTwo.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة 1 من 2'**
  String get stepOneOfTwo;

  /// No description provided for @registerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك بتساعدنا نوصّلك بالطلبات المناسبة ليك.'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسمك الكامل'**
  String get fullNameHint;

  /// No description provided for @yourBloodType.
  ///
  /// In ar, this message translates to:
  /// **'فصيلة دمك'**
  String get yourBloodType;

  /// No description provided for @chooseBloodType.
  ///
  /// In ar, this message translates to:
  /// **'اختار فصيلة دمك'**
  String get chooseBloodType;

  /// No description provided for @governorateLabel.
  ///
  /// In ar, this message translates to:
  /// **'المحافظة'**
  String get governorateLabel;

  /// No description provided for @governorateHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب محافظتك'**
  String get governorateHint;

  /// No description provided for @continueAction.
  ///
  /// In ar, this message translates to:
  /// **'كمّل'**
  String get continueAction;

  /// No description provided for @recoverySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ولا يهمك، اكتب رقم الموبايل المرتبط بحسابك علشان تسترجع كلمة السر.'**
  String get recoverySubtitle;

  /// No description provided for @sendRecoveryCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال كود الاسترجاع'**
  String get sendRecoveryCode;

  /// No description provided for @rememberPassword.
  ///
  /// In ar, this message translates to:
  /// **'افتكرت كلمة السر؟'**
  String get rememberPassword;

  /// No description provided for @requiredField.
  ///
  /// In ar, this message translates to:
  /// **'من فضلك كمّل البيانات'**
  String get requiredField;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رقم موبايل مصري صحيح'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة السر لازم تكون 8 حروف على الأقل'**
  String get passwordTooShort;

  /// No description provided for @showPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كلمة السر'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء كلمة السر'**
  String get hidePassword;

  /// No description provided for @authUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة دي مش متاحة حالياً.'**
  String get authUnavailable;

  /// No description provided for @selectGovernorate.
  ///
  /// In ar, this message translates to:
  /// **'اختار المحافظة'**
  String get selectGovernorate;

  /// No description provided for @districtLabel.
  ///
  /// In ar, this message translates to:
  /// **'المركز / القسم'**
  String get districtLabel;

  /// No description provided for @selectDistrict.
  ///
  /// In ar, this message translates to:
  /// **'اختار المركز أو القسم'**
  String get selectDistrict;

  /// No description provided for @chooseGovernorateFirst.
  ///
  /// In ar, this message translates to:
  /// **'اختار المحافظة الأول'**
  String get chooseGovernorateFirst;

  /// No description provided for @searchLocations.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم...'**
  String get searchLocations;

  /// No description provided for @noLocationsFound.
  ///
  /// In ar, this message translates to:
  /// **'مفيش نتائج للبحث ده'**
  String get noLocationsFound;

  /// No description provided for @loadingLocations.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل المحافظات...'**
  String get loadingLocations;

  /// No description provided for @closeLocations.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get closeLocations;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
