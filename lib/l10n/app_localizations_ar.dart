// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ميزان';

  @override
  String get dashboardTitle => 'ميزان';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'مساء الخير';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get balanceTitle => 'توازن الحياة';

  @override
  String get balanceSubtitle => 'عبادتك ودنياك في انسجام';

  @override
  String get ringSpiritual => 'روحي';

  @override
  String get ringWorldly => 'دنيوي';

  @override
  String get spiritualHubTitle => 'المركز الروحي';

  @override
  String get prayersToday => 'صلوات اليوم';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get quranWird => 'ورد القرآن';

  @override
  String quranPages(int done, int goal) {
    return '$done من $goal صفحات';
  }

  @override
  String get charityGoal => 'هدف الصدقة';

  @override
  String charityAmount(int done, int goal) {
    return '$done من $goal';
  }

  @override
  String get dhikrCounter => 'عدّاد الذكر';

  @override
  String get dhikrTapHint => 'اضغط للعدّ';

  @override
  String get dhikrReset => 'تصفير';

  @override
  String get productivityHubTitle => 'مركز الإنتاجية';

  @override
  String get topTasks => 'أهم المهام';

  @override
  String get noTasks => 'لا مهام متبقية. استمتع بالهدوء.';

  @override
  String get priorityHigh => 'عالية';

  @override
  String get priorityMedium => 'متوسطة';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get taskCompleted => 'مكتملة';

  @override
  String get streakTitle => 'التتابع';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: 'لا تتابع بعد',
    );
    return '$_temp0';
  }

  @override
  String get streakKeepGrowing => 'واظب على الحضور — شجرتك تنمو معك.';

  @override
  String get morningBrief => 'موجز الصباح';

  @override
  String get morningBriefSubtitle => 'يومك في لمحة';

  @override
  String get morningBriefPrayers => 'الصلوات';

  @override
  String get morningBriefWird => 'ورد القرآن';

  @override
  String get morningBriefTasks => 'أهم المهام';

  @override
  String get morningBriefPlay => 'تشغيل الموجز (قريبًا)';

  @override
  String get close => 'إغلاق';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get comingSoonBody => 'هذا الجزء من ميزان في الطريق.';

  @override
  String get navPrayer => 'الصلاة';

  @override
  String get navQuran => 'القرآن';

  @override
  String get navCharity => 'الصدقة';

  @override
  String get navTasks => 'المهام';

  @override
  String get toggleTheme => 'تبديل المظهر';

  @override
  String get toggleLanguage => 'تبديل اللغة';
}
