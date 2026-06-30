// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get rating => 'التقييم';

  @override
  String get reviews => 'المراجعات';

  @override
  String get sessions => 'الجلسات';

  @override
  String get skillsToLearn => 'مهارات أريد تعلمها';

  @override
  String get skillsCanTeach => 'مهارات يمكنني تدريسها';

  @override
  String get addSkill => 'إضافة مهارة';

  @override
  String get manageSkills => 'إدارة المهارات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get sessionHistory => 'سجل الجلسات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get points => 'النقاط';

  @override
  String get topUp => 'شحن';

  @override
  String get withdraw => 'سحب';

  @override
  String get noSkillsAddedYet => 'لم يتم إضافة مهارات بعد.';

  @override
  String get newSkill => 'مهارة جديدة';

  @override
  String get add => 'إضافة';

  @override
  String get close => 'إغلاق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get home => 'الرئيسية';

  @override
  String get search => 'بحث';

  @override
  String get messages => 'الرسائل';

  @override
  String get profile => 'البروفايل';

  @override
  String couldNotLoadProfile(String error) {
    return 'تعذر تحميل ملفك الشخصي: $error';
  }

  @override
  String get goodMorning => 'صباح الخير،';

  @override
  String get goodAfternoon => 'مساء الخير،';

  @override
  String get goodEvening => 'مساء الخير،';

  @override
  String get searchSkillsUsers => 'ابحث عن مهارات، مستخدمين...';

  @override
  String get learn => 'تعلم';

  @override
  String get teach => 'درّس';

  @override
  String get categories => 'التصنيفات';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get recommendedMentors => 'موجهون مقترحون';

  @override
  String get activeRequests => 'طلبات نشطة';

  @override
  String get noActiveRequests => 'لا توجد طلبات نشطة حالياً.';

  @override
  String get letsLearn => 'هيا نتعلم شيئاً اليوم';

  @override
  String get topMentors => 'أفضل الموجهين';

  @override
  String get justForYou => 'خصيصاً لك';

  @override
  String get promo1Title => 'مهارات جديدة تُضاف يومياً';

  @override
  String get promo1Desc => 'اكتشف فرص تعلم جديدة';

  @override
  String get promo2Title => 'ابدأ أول تبادل لك';

  @override
  String get promo2Desc => 'تواصل مع أعضاء مجتمع ماهرين';

  @override
  String get promo3Title => 'اربح مكافآت أثناء المساعدة';

  @override
  String get promo3Desc => 'درّس مهارة واجمع النقاط';

  @override
  String mentorsCount(int count) {
    return '$count موجهين';
  }

  @override
  String get searchHint => 'ابحث عن مهارات، مستخدمين...';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterLatest => 'الأحدث';

  @override
  String get filterMostPopular => 'الأكثر شعبية';

  @override
  String get filterCheapest => 'الأرخص';

  @override
  String get popularSkills => 'مهارات شائعة';

  @override
  String get recentSearches => 'عمليات البحث الأخيرة';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get noMentorsFound => 'لم يتم العثور على موجهين لـ';

  @override
  String get tryDifferentKeyword => 'جرب كلمة بحث أخرى أو تصنيف مختلف';

  @override
  String get noResultsFound => 'لم يتم العثور على نتائج.';

  @override
  String get tagHot => 'شائع';

  @override
  String get tagNew => 'جديد';

  @override
  String get tagPopular => 'مشهور';

  @override
  String get manageSessionsDesc =>
      'إدارة طلبات تبادل المهارات المرسلة إليك ومنك.';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get incomingRequests => 'الطلبات الواردة';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get noSessionsYet => 'لا توجد جلسات بعد';

  @override
  String get sessionsWillAppearHere => 'ستظهر الجلسات هنا بمجرد إنشائها.';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusOngoing => 'جارية';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusRejected => 'مرفوضة';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get joinSession => 'انضمام للجلسة';

  @override
  String startsAt(String time) {
    return 'تبدأ $time';
  }

  @override
  String get btnDecline => 'رفض';

  @override
  String get btnAccept => 'قبول';

  @override
  String get actionDeclined => 'تم الرفض';

  @override
  String get btnDelete => 'حذف';

  @override
  String get cancelSession => 'إلغاء الجلسة';

  @override
  String get cancelSessionConfirm =>
      'هل أنت متأكد أنك تريد إلغاء طلب الجلسة هذا؟';

  @override
  String get btnNo => 'لا';

  @override
  String get btnYesCancel => 'نعم، إلغاء';

  @override
  String get deleteSession => 'حذف الجلسة';

  @override
  String get deleteSessionConfirm =>
      'سيتم إزالة الجلسة نهائياً. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get btnYesDelete => 'نعم، حذف';

  @override
  String get rated => 'تم التقييم';

  @override
  String get rateStudent => 'تقييم الطالب';

  @override
  String get rateTeacher => 'تقييم الموجه';

  @override
  String get searchConversations => 'البحث في المحادثات';

  @override
  String get pleaseSignInChats => 'يرجى تسجيل الدخول لعرض محادثاتك.';

  @override
  String get unableToLoadChats => 'تعذر تحميل المحادثات.';

  @override
  String get noChatsYet =>
      'لا توجد محادثات بعد. ابدأ محادثة من الشاشة الرئيسية.';

  @override
  String get pricePerHour => 'السعر في الساعة';

  @override
  String setBy(String name) {
    return 'محدد بواسطة $name';
  }

  @override
  String pointsAmount(String pts) {
    return '$pts نقطة';
  }

  @override
  String get skillsOffered => 'المهارات المقدمة';

  @override
  String get nextAvailability => 'التوفر القادم';

  @override
  String get mockAvailability => 'اليوم 4:00 م · غداً 10:00 ص · الخميس 2:30 م';

  @override
  String get requestSession => 'طلب جلسة';

  @override
  String get online => 'متصل';

  @override
  String get signInToChat => 'سجل الدخول للمحادثة.';

  @override
  String get unableToLoadMessages => 'تعذر تحميل الرسائل';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد. ابدأ المحادثة.';

  @override
  String get messageHint => 'رسالة...';

  @override
  String get pointsAbbr => 'نقطة';

  @override
  String get earnPointsHint => 'اكسب نقاط عبر تعليم مهاراتك للآخرين.';

  @override
  String get privacySecurityHint =>
      'إعدادات الخصوصية الخاصة بك في مكان آمن. يمكنك إدارة أذونات التطبيق ومشاركة البيانات وإشعارات الأمان هنا.';
}
