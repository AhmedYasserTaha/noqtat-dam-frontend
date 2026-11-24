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
  /// **'قطره دم'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

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

  /// No description provided for @authBrand.
  ///
  /// In ar, this message translates to:
  /// **'قطره دم'**
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
  /// **'اختار فصيلة دمك.'**
  String get chooseBloodType;

  /// No description provided for @governorateLabel.
  ///
  /// In ar, this message translates to:
  /// **'المحافظة'**
  String get governorateLabel;

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

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رقم موبايل مصري صحيح'**
  String get invalidPhone;

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

  /// No description provided for @myRequestsTab.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myRequestsTab;

  /// No description provided for @myAccountTab.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get myAccountTab;

  /// No description provided for @createRequestAction.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء طلب دم'**
  String get createRequestAction;

  /// No description provided for @hospitalVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثّق من المستشفى'**
  String get hospitalVerified;

  /// No description provided for @iWillDonate.
  ///
  /// In ar, this message translates to:
  /// **'أنا هتبرع'**
  String get iWillDonate;

  /// No description provided for @shareRequest.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الطلب'**
  String get shareRequest;

  /// No description provided for @urgentLabel.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get urgentLabel;

  /// No description provided for @donateAction.
  ///
  /// In ar, this message translates to:
  /// **'تبرّع'**
  String get donateAction;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterMyBlood.
  ///
  /// In ar, this message translates to:
  /// **'فصيلتي'**
  String get filterMyBlood;

  /// No description provided for @filterNearby.
  ///
  /// In ar, this message translates to:
  /// **'قريب مني'**
  String get filterNearby;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @requestCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ نص الطلب'**
  String get requestCopied;

  /// No description provided for @staticAccountPreview.
  ///
  /// In ar, this message translates to:
  /// **'بيانات تجريبية · للعرض فقط'**
  String get staticAccountPreview;

  /// No description provided for @requestActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get requestActive;

  /// No description provided for @requestComplete.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get requestComplete;

  /// No description provided for @requestCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغية'**
  String get requestCancelled;

  /// No description provided for @requestDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الطلب:'**
  String get requestDateLabel;

  /// No description provided for @bagsCollectedLabel.
  ///
  /// In ar, this message translates to:
  /// **'أكياس تم تجميعها'**
  String get bagsCollectedLabel;

  /// No description provided for @requestDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get requestDetails;

  /// No description provided for @editProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfileTitle;

  /// No description provided for @personalInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الشخصية'**
  String get personalInfoTitle;

  /// No description provided for @donationInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التبرع'**
  String get donationInfoTitle;

  /// No description provided for @lastDonationLabel.
  ///
  /// In ar, this message translates to:
  /// **'آخر تبرع'**
  String get lastDonationLabel;

  /// No description provided for @availabilityLabel.
  ///
  /// In ar, this message translates to:
  /// **'متاح للتبرع'**
  String get availabilityLabel;

  /// No description provided for @donationHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل التبرعات'**
  String get donationHistoryTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get languageLabel;

  /// No description provided for @languagePreviewBody.
  ///
  /// In ar, this message translates to:
  /// **'الواجهة متاحة بالعربية والإنجليزية. تغيير اللغة من الإعدادات هيتضاف لاحقًا.'**
  String get languagePreviewBody;

  /// No description provided for @supportAndLegalTitle.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والمعلومات'**
  String get supportAndLegalTitle;

  /// No description provided for @privacyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyTitle;

  /// No description provided for @termsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutTitle;

  /// No description provided for @helpTitle.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والأسئلة الشائعة'**
  String get helpTitle;

  /// No description provided for @versionLabel.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get versionLabel;

  /// No description provided for @logoutAction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logoutAction;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccountTitle;

  /// No description provided for @keepAccountAction.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ بالحساب'**
  String get keepAccountAction;

  /// No description provided for @policyDraftNotice.
  ///
  /// In ar, this message translates to:
  /// **'النص ده بيوصف شغل التطبيق حاليًا. مش سياسة قانونية.'**
  String get policyDraftNotice;

  /// No description provided for @privacyDataTitle.
  ///
  /// In ar, this message translates to:
  /// **'البيانات اللي بنحتفظ بيها'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In ar, this message translates to:
  /// **'اسمك ورقم موبايلك وفصيلة دمك وموقعك وحالة إتاحتك والطلبات والتعهدات والمنشورات اللي بتعملها بتتخزن على سيرفر التطبيق. رقم التواصل في الطلب بيظهر بس للي بيتعهد بالتبرع. بيانات التبرع هي اللي سجلتها بنفسك.'**
  String get privacyDataBody;

  /// No description provided for @privacyContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التواصل والموقع'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In ar, this message translates to:
  /// **'متكتبش بيانات مريض حقيقية في الطلب. استخدم بس اللي يلزم للتنسيق، زي المستشفى والفصيلة ورقم تواصل.'**
  String get privacyContactBody;

  /// No description provided for @privacyControlTitle.
  ///
  /// In ar, this message translates to:
  /// **'حقوق المستخدم والتواصل'**
  String get privacyControlTitle;

  /// No description provided for @privacyControlBody.
  ///
  /// In ar, this message translates to:
  /// **'تقدر تعدّل بياناتك وتحذف حسابك من الملف الشخصي. الحذف بيشيل حسابك وطلباتك وتعهداتك من السيرفر.'**
  String get privacyControlBody;

  /// No description provided for @termsUseTitle.
  ///
  /// In ar, this message translates to:
  /// **'الغرض من التطبيق'**
  String get termsUseTitle;

  /// No description provided for @termsUseBody.
  ///
  /// In ar, this message translates to:
  /// **'قطره دم بيساعد الناس تتواصل حول احتياجات التبرع بالدم. التطبيق مش بيتحقق من الطلبات ولا المتبرعين ولا التبرعات.'**
  String get termsUseBody;

  /// No description provided for @termsAccuracyTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى والاستخدام المسؤول'**
  String get termsAccuracyTitle;

  /// No description provided for @termsAccuracyBody.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات والمنشورات بيكتبها المستخدمين. التطبيق مش بيراجعها ولا بيتأكد منها، ومفيش إبلاغ أو مراجعة جوه التطبيق لحد دلوقتي.'**
  String get termsAccuracyBody;

  /// No description provided for @termsMedicalTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنسيق مع المستشفى'**
  String get termsMedicalTitle;

  /// No description provided for @termsMedicalBody.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق مش بيحدد لو حد ينفع يتبرع ولا أي فصيلة مناسبة. اتأكد من ده مع المستشفى. في الطوارئ تواصل مع المستشفى أو الإسعاف مباشرة.'**
  String get termsMedicalBody;

  /// No description provided for @aboutBody.
  ///
  /// In ar, this message translates to:
  /// **'قطره دم بيجمع طلبات الدم والمتبرعين في مكان واحد. التصميم عربي أولًا مع دعم الإنجليزية. التطبيق مش بيتحقق من التبرعات ولا بيدّي نصيحة طبية.'**
  String get aboutBody;

  /// No description provided for @helpRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'إزاي أعمل طلب؟'**
  String get helpRequestTitle;

  /// No description provided for @helpRequestBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط +، واختار الفصيلة وعدد الأكياس والمستشفى ودرجة الاستعجال، راجع وبعدين انشر. المتبرعين اللي بيتعهدوا بيشوفوا رقم تواصلك. تقدر تعلّم الطلب إنه اتغطى أو تلغيه من طلباتي.'**
  String get helpRequestBody;

  /// No description provided for @helpDonateTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل زر التبرع بيحجز تبرع؟'**
  String get helpDonateTitle;

  /// No description provided for @helpDonateBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط \"هتبرع\" على الطلب علشان تتعهد. هيظهرلك رقم صاحب الطلب علشان تتصل وتتأكد. المستشفى هي اللي تقرر لو ينفع تتبرع. \"تبرعت\" هو تسجيل منك أنت بس.'**
  String get helpDonateBody;

  /// No description provided for @helpContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع الدعم'**
  String get helpContactTitle;

  /// No description provided for @helpContactBody.
  ///
  /// In ar, this message translates to:
  /// **'مفيش قناة دعم جوه التطبيق لحد دلوقتي.'**
  String get helpContactBody;

  /// No description provided for @createRequestSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدّد احتياجك وراجع الطلب قبل النشر.'**
  String get createRequestSubtitle;

  /// No description provided for @requiredBloodType.
  ///
  /// In ar, this message translates to:
  /// **'فصيلة الدم المطلوبة'**
  String get requiredBloodType;

  /// No description provided for @numberOfBags.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأكياس'**
  String get numberOfBags;

  /// No description provided for @bagsNeededLabel.
  ///
  /// In ar, this message translates to:
  /// **'أكياس دم مطلوبة'**
  String get bagsNeededLabel;

  /// No description provided for @increaseBags.
  ///
  /// In ar, this message translates to:
  /// **'زيادة عدد الأكياس'**
  String get increaseBags;

  /// No description provided for @decreaseBags.
  ///
  /// In ar, this message translates to:
  /// **'تقليل عدد الأكياس'**
  String get decreaseBags;

  /// No description provided for @hospitalNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستشفى'**
  String get hospitalNameLabel;

  /// No description provided for @hospitalNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم المستشفى'**
  String get hospitalNameHint;

  /// No description provided for @urgencyLabel.
  ///
  /// In ar, this message translates to:
  /// **'درجة الاستعجال'**
  String get urgencyLabel;

  /// No description provided for @urgencyCritical.
  ///
  /// In ar, this message translates to:
  /// **'عاجل جدًا'**
  String get urgencyCritical;

  /// No description provided for @urgencyCriticalHint.
  ///
  /// In ar, this message translates to:
  /// **'احتياج في أقرب وقت'**
  String get urgencyCriticalHint;

  /// No description provided for @urgencyDay.
  ///
  /// In ar, this message translates to:
  /// **'خلال 24 ساعة'**
  String get urgencyDay;

  /// No description provided for @urgencyDayHint.
  ///
  /// In ar, this message translates to:
  /// **'احتياج خلال اليوم'**
  String get urgencyDayHint;

  /// No description provided for @urgencyScheduled.
  ///
  /// In ar, this message translates to:
  /// **'موعد محدد'**
  String get urgencyScheduled;

  /// No description provided for @urgencyScheduledHint.
  ///
  /// In ar, this message translates to:
  /// **'حدّد اليوم والوقت المناسبين'**
  String get urgencyScheduledHint;

  /// No description provided for @deadlineLabel.
  ///
  /// In ar, this message translates to:
  /// **'آخر موعد للتبرع'**
  String get deadlineLabel;

  /// No description provided for @chooseDeadline.
  ///
  /// In ar, this message translates to:
  /// **'اختار اليوم والوقت'**
  String get chooseDeadline;

  /// No description provided for @contactPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم التواصل'**
  String get contactPhoneLabel;

  /// No description provided for @contactPreviewHint.
  ///
  /// In ar, this message translates to:
  /// **'بيظهر بس للمتبرعين اللي بيتعهدوا بالطلب ده.'**
  String get contactPreviewHint;

  /// No description provided for @requestNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات إضافية'**
  String get requestNotesLabel;

  /// No description provided for @requestNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'أي تفاصيل تحب تضيفها عن الطلب...'**
  String get requestNotesHint;

  /// No description provided for @reviewRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الطلب'**
  String get reviewRequestTitle;

  /// No description provided for @requestPreviewNotice.
  ///
  /// In ar, this message translates to:
  /// **'راجع البيانات. تفاصيل الطلب هتظهر لباقي المستخدمين في الصفحة الرئيسية. رقم التواصل بيظهر بس لصاحب الطلب وللمتبرعين اللي تعهدوا بالتبرع.'**
  String get requestPreviewNotice;

  /// No description provided for @previewNotSpecified.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم التحديد'**
  String get previewNotSpecified;

  /// No description provided for @confirmRequestPreview.
  ///
  /// In ar, this message translates to:
  /// **'نشر الطلب'**
  String get confirmRequestPreview;

  /// No description provided for @editRequestPreview.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البيانات'**
  String get editRequestPreview;

  /// No description provided for @requestPreviewDone.
  ///
  /// In ar, this message translates to:
  /// **'تم نشر الطلب'**
  String get requestPreviewDone;

  /// No description provided for @requestNotPublished.
  ///
  /// In ar, this message translates to:
  /// **'طلبك بقى ظاهر. المتبرعين اللي بيتعهدوا هيشوفوا رقم تواصلك. تقدر تديره من طلباتي.'**
  String get requestNotPublished;

  /// No description provided for @viewMyRequests.
  ///
  /// In ar, this message translates to:
  /// **'عرض طلباتي'**
  String get viewMyRequests;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع للرئيسية'**
  String get backToHome;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'الحقل ده مطلوب'**
  String get fieldRequired;

  /// No description provided for @errInvalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رقم موبايل مصري صحيح، مثلًا 010 1234 5678.'**
  String get errInvalidPhone;

  /// No description provided for @errWeakPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور لازم تكون 8 حروف أو أرقام على الأقل.'**
  String get errWeakPassword;

  /// No description provided for @errPhoneTaken.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل ده مسجل قبل كده. جرّب تسجّل دخول.'**
  String get errPhoneTaken;

  /// No description provided for @errWrongCredentials.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل أو كلمة المرور غلط.'**
  String get errWrongCredentials;

  /// No description provided for @errInvalidCode.
  ///
  /// In ar, this message translates to:
  /// **'الكود غلط أو انتهت صلاحيته.'**
  String get errInvalidCode;

  /// No description provided for @errNeedGovernorate.
  ///
  /// In ar, this message translates to:
  /// **'حدّد المحافظة الأول وبعدين جرّب تاني.'**
  String get errNeedGovernorate;

  /// No description provided for @errTooMany.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كتير. استنى كام دقيقة وجرّب تاني.'**
  String get errTooMany;

  /// No description provided for @errNetwork.
  ///
  /// In ar, this message translates to:
  /// **'مش قادر أوصل للسيرفر. اتأكد من الإنترنت وجرّب تاني.'**
  String get errNetwork;

  /// No description provided for @errServer.
  ///
  /// In ar, this message translates to:
  /// **'حصلت مشكلة في السيرفر. جرّب بعد شوية.'**
  String get errServer;

  /// No description provided for @errNotFound.
  ///
  /// In ar, this message translates to:
  /// **'العنصر ده لم يعد موجودًا.'**
  String get errNotFound;

  /// No description provided for @errPermission.
  ///
  /// In ar, this message translates to:
  /// **'مش مسموح لك بالإجراء ده.'**
  String get errPermission;

  /// No description provided for @errUnauthorized.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. سجّل دخول تاني.'**
  String get errUnauthorized;

  /// No description provided for @errGeneric.
  ///
  /// In ar, this message translates to:
  /// **'ماقدرناش نكمل. راجع البيانات وجرّب تاني.'**
  String get errGeneric;

  /// No description provided for @chooseLocation.
  ///
  /// In ar, this message translates to:
  /// **'اختار المحافظة والمركز.'**
  String get chooseLocation;

  /// No description provided for @resetCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'كود الاستعادة'**
  String get resetCodeLabel;

  /// No description provided for @resetCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الكود اللي وصلك واختار كلمة مرور جديدة.'**
  String get resetCodeHint;

  /// No description provided for @newPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPasswordLabel;

  /// No description provided for @resetDone.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور. سجّل دخول بالجديدة.'**
  String get resetDone;

  /// No description provided for @resetPasswordAction.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get resetPasswordAction;

  /// No description provided for @createAccountAction.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get createAccountAction;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @closestRequest.
  ///
  /// In ar, this message translates to:
  /// **'أقرب طلب'**
  String get closestRequest;

  /// No description provided for @markedAvailable.
  ///
  /// In ar, this message translates to:
  /// **'حاليًا حاطط نفسك متاح للتبرع'**
  String get markedAvailable;

  /// No description provided for @markedUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'حاليًا حاطط نفسك غير متاح'**
  String get markedUnavailable;

  /// No description provided for @noDonationsRecorded.
  ///
  /// In ar, this message translates to:
  /// **'لسه مفيش تبرعات مسجلة'**
  String get noDonationsRecorded;

  /// No description provided for @selfReportedCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{تبرع واحد} =2{تبرعان} few{{count} تبرعات} other{{count} تبرعًا}} · من تسجيلك'**
  String selfReportedCount(int count);

  /// No description provided for @selfReportedLast.
  ///
  /// In ar, this message translates to:
  /// **'آخر تبرع {date} · {count, plural, =1{تبرع واحد} =2{تبرعان} few{{count} تبرعات} other{{count} تبرعًا}} · من تسجيلك'**
  String selfReportedLast(String date, int count);

  /// No description provided for @bagsNeeded.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{مطلوب كيس دم واحد} =2{مطلوب كيسا دم} few{مطلوب {count} أكياس دم} other{مطلوب {count} كيس دم}}'**
  String bagsNeeded(int count);

  /// No description provided for @collectedOf.
  ///
  /// In ar, this message translates to:
  /// **'اتجمّع {collected} من {needed}'**
  String collectedOf(int collected, int needed);

  /// No description provided for @onTheWayCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لسه مفيش حد في الطريق} =1{واحد في الطريق} =2{اتنين في الطريق} few{{count} في الطريق} other{{count} في الطريق}}'**
  String onTheWayCount(int count);

  /// No description provided for @viewPledge.
  ///
  /// In ar, this message translates to:
  /// **'تعهّدي'**
  String get viewPledge;

  /// No description provided for @chooseLocationChip.
  ///
  /// In ar, this message translates to:
  /// **'اختار الموقع'**
  String get chooseLocationChip;

  /// No description provided for @noNotificationsYet.
  ///
  /// In ar, this message translates to:
  /// **'مفيش إشعارات لسه.'**
  String get noNotificationsYet;

  /// No description provided for @noRequestsYet.
  ///
  /// In ar, this message translates to:
  /// **'مفيش طلبات للعرض.'**
  String get noRequestsYet;

  /// No description provided for @pledgeTitle.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا على تعهّدك'**
  String get pledgeTitle;

  /// No description provided for @phoneCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الرقم'**
  String get phoneCopied;

  /// No description provided for @pledgeNote.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بصاحب الطلب علشان تتأكد من المستشفى والميعاد. المستشفى هي اللي تقرر لو ينفع تتبرع. اضغط \"تبرعت\" بعد ما تتبرع فعلًا: ده تسجيل منك أنت ومحدش بيتحقق منه.'**
  String get pledgeNote;

  /// No description provided for @iDonated.
  ///
  /// In ar, this message translates to:
  /// **'تبرعت (تسجيل مني)'**
  String get iDonated;

  /// No description provided for @cancelPledge.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تعهّدي'**
  String get cancelPledge;

  /// No description provided for @shareTextBody.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب دم: {bags, plural, =1{كيس واحد} =2{كيسان} few{{bags} أكياس} other{{bags} كيس}} فصيلة {type} في {hospital}، {place}. افتح تطبيق قطره دم للمساعدة.'**
  String shareTextBody(int bags, String type, String hospital, String place);

  /// No description provided for @deadlinePassed.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الموعد'**
  String get deadlinePassed;

  /// No description provided for @daysLeft.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{باقي يوم} =2{باقي يومان} few{باقي {count} أيام} other{باقي {count} يومًا}}'**
  String daysLeft(int count);

  /// No description provided for @hoursLeft.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{باقي ساعة} =2{باقي ساعتان} few{باقي {count} ساعات} other{باقي {count} ساعة}}'**
  String hoursLeft(int count);

  /// No description provided for @minutesLeft.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{باقي دقيقة} =2{باقي دقيقتان} few{باقي {count} دقائق} other{باقي {count} دقيقة}}'**
  String minutesLeft(int count);

  /// No description provided for @requestMissingFields.
  ///
  /// In ar, this message translates to:
  /// **'اكتب المستشفى والمركز ورقم تواصل الأول.'**
  String get requestMissingFields;

  /// No description provided for @requestNeedsDeadline.
  ///
  /// In ar, this message translates to:
  /// **'اختار تاريخ ووقت للطلب المجدول.'**
  String get requestNeedsDeadline;

  /// No description provided for @myRequestsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات اللي نشرتها'**
  String get myRequestsSubtitle;

  /// No description provided for @markFulfilled.
  ///
  /// In ar, this message translates to:
  /// **'تم تغطية الطلب'**
  String get markFulfilled;

  /// No description provided for @cancelRequest.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get cancelRequest;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @profileSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get profileSaved;

  /// No description provided for @accountSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابك وبيانات التبرع'**
  String get accountSubtitle;

  /// No description provided for @memberSince.
  ///
  /// In ar, this message translates to:
  /// **'عضو منذ {date}'**
  String memberSince(String date);

  /// No description provided for @notSet.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get notSet;

  /// No description provided for @selfReportedTag.
  ///
  /// In ar, this message translates to:
  /// **'من تسجيلك'**
  String get selfReportedTag;

  /// No description provided for @selfReportedNote.
  ///
  /// In ar, this message translates to:
  /// **'التسجيلات دي منك أنت. مش متحقق منها ولا بتوضح لو ينفع تتبرع.'**
  String get selfReportedNote;

  /// No description provided for @availabilityHint.
  ///
  /// In ar, this message translates to:
  /// **'بيظهر لأصحاب الطلبات إنك متاح. مش فحص طبي.'**
  String get availabilityHint;

  /// No description provided for @notificationsHint.
  ///
  /// In ar, this message translates to:
  /// **'تفضيلك. الإشعارات على الموبايل لسه مش متفعلة.'**
  String get notificationsHint;

  /// No description provided for @deleteAccountBody.
  ///
  /// In ar, this message translates to:
  /// **'ده هيحذف حسابك وطلباتك وتعهداتك نهائيًا ومش هينفع تتراجع.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف نهائي'**
  String get deleteAccountConfirm;

  /// No description provided for @createChoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنت عاوز تنشر إيه؟'**
  String get createChoiceTitle;

  /// No description provided for @createPostOption.
  ///
  /// In ar, this message translates to:
  /// **'بوست'**
  String get createPostOption;

  /// No description provided for @createPostHint.
  ///
  /// In ar, this message translates to:
  /// **'كلام عادي للمجتمع، والناس تقدر تعمل لايك أو ديس لايك.'**
  String get createPostHint;

  /// No description provided for @createRequestOption.
  ///
  /// In ar, this message translates to:
  /// **'طلب دم'**
  String get createRequestOption;

  /// No description provided for @createRequestHint.
  ///
  /// In ar, this message translates to:
  /// **'طلب محتاج متبرعين بفصيلة معينة في مستشفى.'**
  String get createRequestHint;

  /// No description provided for @newPostTitle.
  ///
  /// In ar, this message translates to:
  /// **'بوست جديد'**
  String get newPostTitle;

  /// No description provided for @newPostField.
  ///
  /// In ar, this message translates to:
  /// **'اكتب بوستك'**
  String get newPostField;

  /// No description provided for @newPostPublish.
  ///
  /// In ar, this message translates to:
  /// **'نشر البوست'**
  String get newPostPublish;

  /// No description provided for @newPostEmpty.
  ///
  /// In ar, this message translates to:
  /// **'اكتب حاجة الأول.'**
  String get newPostEmpty;

  /// No description provided for @newPostWarning.
  ///
  /// In ar, this message translates to:
  /// **'متكتبش بيانات مريض أو أرقام تليفونات في البوست.'**
  String get newPostWarning;

  /// No description provided for @postPublished.
  ///
  /// In ar, this message translates to:
  /// **'تم نشر البوست.'**
  String get postPublished;

  /// No description provided for @likeAction.
  ///
  /// In ar, this message translates to:
  /// **'لايك'**
  String get likeAction;

  /// No description provided for @dislikeAction.
  ///
  /// In ar, this message translates to:
  /// **'ديس لايك'**
  String get dislikeAction;

  /// No description provided for @reportAction.
  ///
  /// In ar, this message translates to:
  /// **'إبلاغ'**
  String get reportAction;

  /// No description provided for @deletePostAction.
  ///
  /// In ar, this message translates to:
  /// **'حذف البوست'**
  String get deletePostAction;

  /// No description provided for @postDeleted.
  ///
  /// In ar, this message translates to:
  /// **'اتحذف البوست.'**
  String get postDeleted;

  /// No description provided for @reportTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإبلاغ'**
  String get reportTitle;

  /// No description provided for @reportSpam.
  ///
  /// In ar, this message translates to:
  /// **'إعلان أو سبام'**
  String get reportSpam;

  /// No description provided for @reportFake.
  ///
  /// In ar, this message translates to:
  /// **'محتوى مزيف'**
  String get reportFake;

  /// No description provided for @reportAbusive.
  ///
  /// In ar, this message translates to:
  /// **'مسيء'**
  String get reportAbusive;

  /// No description provided for @reportSensitive.
  ///
  /// In ar, this message translates to:
  /// **'فيه بيانات حساسة'**
  String get reportSensitive;

  /// No description provided for @reportOther.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر'**
  String get reportOther;

  /// No description provided for @reportDone.
  ///
  /// In ar, this message translates to:
  /// **'تم الإبلاغ وهنخفي ده عنك. المراجعة بتتم يدويًا من صاحب التطبيق، ومفيش إخفاء تلقائي للباقي.'**
  String get reportDone;

  /// No description provided for @loadMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get loadMore;

  /// No description provided for @loadMoreFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المزيد.'**
  String get loadMoreFailed;

  /// No description provided for @pledgesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المتبرعون المتعهدون'**
  String get pledgesTitle;

  /// No description provided for @pledgesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لسه محدش اتعهد.'**
  String get pledgesEmpty;

  /// No description provided for @pledgeOnTheWay.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get pledgeOnTheWay;

  /// No description provided for @pledgeDonated.
  ///
  /// In ar, this message translates to:
  /// **'قال إنه تبرع'**
  String get pledgeDonated;

  /// No description provided for @notificationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'مفيش إشعارات لسه.'**
  String get notificationsEmpty;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تعليم الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @shareFailedCopied.
  ///
  /// In ar, this message translates to:
  /// **'اتنسخ النص لأن المشاركة مش متاحة.'**
  String get shareFailedCopied;

  /// No description provided for @postsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المنشورات'**
  String get postsTitle;

  /// No description provided for @postsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منشورات حتى الآن'**
  String get postsEmpty;

  /// No description provided for @chooseHospital.
  ///
  /// In ar, this message translates to:
  /// **'اختار المستشفى'**
  String get chooseHospital;

  /// No description provided for @searchHospitals.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم المستشفى'**
  String get searchHospitals;

  /// No description provided for @noHospitalsFound.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مستشفى بالاسم ده'**
  String get noHospitalsFound;

  /// No description provided for @hospitalNotListed.
  ///
  /// In ar, this message translates to:
  /// **'مستشفى تانية، هكتب اسمها'**
  String get hospitalNotListed;

  /// No description provided for @chooseFromHospitalList.
  ///
  /// In ar, this message translates to:
  /// **'اختار من قائمة المستشفيات'**
  String get chooseFromHospitalList;

  /// No description provided for @openHospitalInMaps.
  ///
  /// In ar, this message translates to:
  /// **'روح للمستشفى في الخرائط'**
  String get openHospitalInMaps;

  /// No description provided for @searchHospitalInMaps.
  ///
  /// In ar, this message translates to:
  /// **'دوّر عليها في الخرائط'**
  String get searchHospitalInMaps;

  /// No description provided for @hospitalLocationUnreviewed.
  ///
  /// In ar, this message translates to:
  /// **'مكان المستشفى لسه متراجعش، اتأكد منه في الخرائط.'**
  String get hospitalLocationUnreviewed;

  /// No description provided for @hospitalTypedByHand.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستشفى مكتوب بإيد صاحب الطلب، واتأكد إن نتيجة الخرائط هي المستشفى الصح.'**
  String get hospitalTypedByHand;

  /// No description provided for @mapsOpenFailed.
  ///
  /// In ar, this message translates to:
  /// **'مقدرناش نفتح الخرائط'**
  String get mapsOpenFailed;
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
