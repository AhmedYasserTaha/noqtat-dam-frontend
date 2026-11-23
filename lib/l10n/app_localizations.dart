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

  /// No description provided for @mapTab.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة'**
  String get mapTab;

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

  /// No description provided for @readyToDonate.
  ///
  /// In ar, this message translates to:
  /// **'جاهز تتبرع تاني'**
  String get readyToDonate;

  /// No description provided for @donationHistoryDemo.
  ///
  /// In ar, this message translates to:
  /// **'آخر تبرع من 4 شهور · 3 تبرعات سابقة'**
  String get donationHistoryDemo;

  /// No description provided for @closestUrgentRequest.
  ///
  /// In ar, this message translates to:
  /// **'عاجل جدًا · أقرب طلب ليك'**
  String get closestUrgentRequest;

  /// No description provided for @threeHoursLeft.
  ///
  /// In ar, this message translates to:
  /// **'باقي 3 ساعات'**
  String get threeHoursLeft;

  /// No description provided for @threeBagsNeeded.
  ///
  /// In ar, this message translates to:
  /// **'3 أكياس دم مطلوبة'**
  String get threeBagsNeeded;

  /// No description provided for @mansouraHospitalDistance.
  ///
  /// In ar, this message translates to:
  /// **'مستشفى المنصورة الجامعي · 2.4 كم'**
  String get mansouraHospitalDistance;

  /// No description provided for @hospitalVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثّق من المستشفى'**
  String get hospitalVerified;

  /// No description provided for @oneOfThreeCollected.
  ///
  /// In ar, this message translates to:
  /// **'اتجمع 1 من 3'**
  String get oneOfThreeCollected;

  /// No description provided for @twoOnTheWay.
  ///
  /// In ar, this message translates to:
  /// **'2 في الطريق'**
  String get twoOnTheWay;

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

  /// No description provided for @demoDonorName.
  ///
  /// In ar, this message translates to:
  /// **'محمد أحمد'**
  String get demoDonorName;

  /// No description provided for @twoHoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'من ساعتين'**
  String get twoHoursAgo;

  /// No description provided for @demoDonationPost.
  ///
  /// In ar, this message translates to:
  /// **'النهاردة تبرعت بالدم لأول مرة، والإحساس مش بيتوصف. لو بتفكر تتبرع متترددش!'**
  String get demoDonationPost;

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

  /// No description provided for @mansouraCity.
  ///
  /// In ar, this message translates to:
  /// **'المنصورة'**
  String get mansouraCity;

  /// No description provided for @demoFeedLabel.
  ///
  /// In ar, this message translates to:
  /// **'معاينة التصميم · بيانات تجريبية'**
  String get demoFeedLabel;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @noDemoNotifications.
  ///
  /// In ar, this message translates to:
  /// **'مفيش إشعارات في المعاينة دي.'**
  String get noDemoNotifications;

  /// No description provided for @demoDonationNotice.
  ///
  /// In ar, this message translates to:
  /// **'ده طلب تجريبي لعرض التصميم. مش هيتم تسجيل تعهّد بالتبرع.'**
  String get demoDonationNotice;

  /// No description provided for @demoShareText.
  ///
  /// In ar, this message translates to:
  /// **'طلب تجريبي: 3 أكياس O- في مستشفى المنصورة الجامعي. للمعاينة فقط، مش طلب تبرع حقيقي.'**
  String get demoShareText;

  /// No description provided for @requestCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ نص الطلب التجريبي'**
  String get requestCopied;

  /// No description provided for @twoBagsTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيسين دم'**
  String get twoBagsTitle;

  /// No description provided for @talkhaHospitalDistance.
  ///
  /// In ar, this message translates to:
  /// **'مستشفى طلخا العام · 11 كم'**
  String get talkhaHospitalDistance;

  /// No description provided for @plateletsTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيس صفائح دموية'**
  String get plateletsTitle;

  /// No description provided for @salamHospitalDistance.
  ///
  /// In ar, this message translates to:
  /// **'مستشفى السلام · 5 كم'**
  String get salamHospitalDistance;

  /// No description provided for @matchingFeaturedRequest.
  ///
  /// In ar, this message translates to:
  /// **'الطلب المميز فوق مطابق لفصيلتك التجريبية O-'**
  String get matchingFeaturedRequest;

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

  /// No description provided for @demoUniversityHospital.
  ///
  /// In ar, this message translates to:
  /// **'مستشفى المنصورة الجامعي'**
  String get demoUniversityHospital;

  /// No description provided for @demoTalkhaHospital.
  ///
  /// In ar, this message translates to:
  /// **'مستشفى طلخا العام'**
  String get demoTalkhaHospital;

  /// No description provided for @demoSalamHospital.
  ///
  /// In ar, this message translates to:
  /// **'مستشفى السلام'**
  String get demoSalamHospital;

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

  /// No description provided for @demoRequestNotes.
  ///
  /// In ar, this message translates to:
  /// **'طلب تجريبي لعرض احتياج المستشفى لفصيلة الدم. بيانات المكان والتبرعات ليست طلبًا حقيقيًا.'**
  String get demoRequestNotes;

  /// No description provided for @editProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfileTitle;

  /// No description provided for @localEditNotice.
  ///
  /// In ar, this message translates to:
  /// **'تغيير تجريبي في الواجهة فقط'**
  String get localEditNotice;

  /// No description provided for @savePreview.
  ///
  /// In ar, this message translates to:
  /// **'حفظ للمعاينة'**
  String get savePreview;

  /// No description provided for @demoMemberSince.
  ///
  /// In ar, this message translates to:
  /// **'متبرع من يناير 2026'**
  String get demoMemberSince;

  /// No description provided for @donationsStat.
  ///
  /// In ar, this message translates to:
  /// **'تبرعات سابقة'**
  String get donationsStat;

  /// No description provided for @requestsStat.
  ///
  /// In ar, this message translates to:
  /// **'طلبات نشطة'**
  String get requestsStat;

  /// No description provided for @monthsSinceStat.
  ///
  /// In ar, this message translates to:
  /// **'شهور من آخر تبرع'**
  String get monthsSinceStat;

  /// No description provided for @personalInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الشخصية'**
  String get personalInfoTitle;

  /// No description provided for @emailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailLabel;

  /// No description provided for @demoGovernorate.
  ///
  /// In ar, this message translates to:
  /// **'الدقهلية'**
  String get demoGovernorate;

  /// No description provided for @birthDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد'**
  String get birthDateLabel;

  /// No description provided for @genderLabel.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get genderLabel;

  /// No description provided for @maleLabel.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get maleLabel;

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

  /// No description provided for @demoDonationHistory.
  ///
  /// In ar, this message translates to:
  /// **'23/07/2026 · مستشفى المنصورة الجامعي\n12/03/2026 · مستشفى طلخا العام\n08/01/2026 · مستشفى السلام\n\nسجل تجريبي، لا يثبت أهلية التبرع.'**
  String get demoDonationHistory;

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

  /// No description provided for @deletePreviewBody.
  ///
  /// In ar, this message translates to:
  /// **'ده تأكيد تجريبي لشكل حذف الحساب. مفيش حساب حقيقي هيتحذف أو بيانات هتتمسح.'**
  String get deletePreviewBody;

  /// No description provided for @keepAccountAction.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ بالحساب'**
  String get keepAccountAction;

  /// No description provided for @confirmPreviewAction.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد المعاينة'**
  String get confirmPreviewAction;

  /// No description provided for @noAccountDeleted.
  ///
  /// In ar, this message translates to:
  /// **'دي معاينة بس. لم يتم حذف أي حساب أو بيانات.'**
  String get noAccountDeleted;

  /// No description provided for @policyDraftNotice.
  ///
  /// In ar, this message translates to:
  /// **'مسودة تجريبية لعرض الواجهة، وليست سياسة نهائية أو شروط استخدام سارية. تُراجع وتُحدّث قبل تشغيل الخدمات الفعلية.'**
  String get policyDraftNotice;

  /// No description provided for @privacyDataTitle.
  ///
  /// In ar, this message translates to:
  /// **'البيانات في النسخة الحالية'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In ar, this message translates to:
  /// **'الملف والطلبات المعروضة بيانات ثابتة للتجربة. تعديل الاسم أو التفضيلات يغيّر الواجهة مؤقتًا ولا يحفظ بيانات حساب على Firebase. تهيئة Firebase موجودة، لكن ميزات الحسابات والطلبات غير مفعّلة.'**
  String get privacyDataBody;

  /// No description provided for @privacyContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التواصل والموقع'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In ar, this message translates to:
  /// **'عند تفعيل الخدمة، يلزم توضيح البيانات التي تُجمع وسبب جمعها ومن يطلع عليها، خصوصًا رقم الهاتف والموقع وفصيلة الدم. لا تستخدم أرقام أشخاص أو بيانات مرضى حقيقية في هذه المعاينة.'**
  String get privacyContactBody;

  /// No description provided for @privacyControlTitle.
  ///
  /// In ar, this message translates to:
  /// **'حقوق المستخدم والتواصل'**
  String get privacyControlTitle;

  /// No description provided for @privacyControlBody.
  ///
  /// In ar, this message translates to:
  /// **'وسائل طلب الوصول للبيانات وتصحيحها وحذفها، وفترات الاحتفاظ بها، وبيانات مسؤول التواصل ستُحدد قبل الإطلاق. زر حذف الحساب الحالي للعرض فقط.'**
  String get privacyControlBody;

  /// No description provided for @termsUseTitle.
  ///
  /// In ar, this message translates to:
  /// **'الغرض من التطبيق'**
  String get termsUseTitle;

  /// No description provided for @termsUseBody.
  ///
  /// In ar, this message translates to:
  /// **'قطره دم مشروع يهدف لتسهيل التواصل حول احتياجات التبرع بالدم. النسخة الحالية تعرض التصميم فقط ولا تؤكد وجود طلبات حقيقية أو متبرعين أو حجوزات.'**
  String get termsUseBody;

  /// No description provided for @termsAccuracyTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى والاستخدام المسؤول'**
  String get termsAccuracyTitle;

  /// No description provided for @termsAccuracyBody.
  ///
  /// In ar, this message translates to:
  /// **'عند إطلاق الخدمة، يجب تقديم بيانات صحيحة واحترام خصوصية الآخرين، وعدم نشر طلبات مضللة أو محتوى مسيء أو بيع الدم أو استغلال المحتاجين. إجراءات المراجعة والإبلاغ ستُوضح ضمن الشروط النهائية.'**
  String get termsAccuracyBody;

  /// No description provided for @termsMedicalTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنسيق مع المستشفى'**
  String get termsMedicalTitle;

  /// No description provided for @termsMedicalBody.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق ليس جهة طبية ولا بديلًا عن المستشفى. أي تبرع فعلي يُنسّق مع جهة طبية مختصة، وهي التي تقرر الأهلية والفحوص المطلوبة. في الطوارئ تواصل مباشرة مع جهة الرعاية المختصة ولا تعتمد على المعاينة.'**
  String get termsMedicalBody;

  /// No description provided for @aboutBody.
  ///
  /// In ar, this message translates to:
  /// **'قطره دم بيجمع فكرة طلبات الدم والمتبرعين في مكان واحد. التصميم عربي أولًا، مع دعم الإنجليزية. كل الطلبات والإحصائيات المعروضة حاليًا بيانات تجريبية، والخدمات الفعلية هتتضاف بعد اكتمال الواجهات.'**
  String get aboutBody;

  /// No description provided for @helpRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'إزاي أعمل طلب؟'**
  String get helpRequestTitle;

  /// No description provided for @helpRequestBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط علامة +، واختار الفصيلة وعدد الأكياس وتفاصيل المستشفى. زر معاينة الطلب يعرض البيانات قبل تأكيد تجريبي؛ لا يتم نشر أو حفظ الطلب حاليًا.'**
  String get helpRequestBody;

  /// No description provided for @helpDonateTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل زر التبرع بيحجز تبرع؟'**
  String get helpDonateTitle;

  /// No description provided for @helpDonateBody.
  ///
  /// In ar, this message translates to:
  /// **'لا، الأزرار الحالية للعرض والتجربة فقط. مش بيتم تسجيل تعهّد أو إرسال إشعار لأي شخص.'**
  String get helpDonateBody;

  /// No description provided for @helpContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع الدعم'**
  String get helpContactTitle;

  /// No description provided for @helpContactBody.
  ///
  /// In ar, this message translates to:
  /// **'قنوات الدعم الرسمية لم تُحدد بعد. بيانات البريد والهاتف في البروفايل أمثلة وليست جهة دعم حقيقية.'**
  String get helpContactBody;

  /// No description provided for @createRequestSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدّد احتياجك وراجع شكل الطلب قبل المتابعة. دي معاينة للواجهة فقط.'**
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
  /// **'رقم للعرض في المعاينة فقط، مش هيتم حفظه أو مشاركته.'**
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
  /// **'معاينة تجريبية بدون نشر أو إرسال إشعارات. الخانات الفاضية مسموحة حاليًا.'**
  String get requestPreviewNotice;

  /// No description provided for @previewNotSpecified.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم التحديد'**
  String get previewNotSpecified;

  /// No description provided for @confirmRequestPreview.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد المعاينة'**
  String get confirmRequestPreview;

  /// No description provided for @editRequestPreview.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البيانات'**
  String get editRequestPreview;

  /// No description provided for @requestPreviewDone.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الطلب جاهزة'**
  String get requestPreviewDone;

  /// No description provided for @requestNotPublished.
  ///
  /// In ar, this message translates to:
  /// **'دي تجربة لشكل إنشاء الطلب بس. لم يتم نشر أو حفظ الطلب، وطلباتي هتفضل تعرض البيانات التجريبية.'**
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
