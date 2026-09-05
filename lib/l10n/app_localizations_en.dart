// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Meezan';

  @override
  String get dashboardTitle => 'Meezan';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get balanceTitle => 'Life Balance';

  @override
  String get balanceSubtitle => 'Your worship and worldly life, in harmony';

  @override
  String get ringSpiritual => 'Spiritual';

  @override
  String get ringWorldly => 'Worldly';

  @override
  String get spiritualHubTitle => 'Spiritual Hub';

  @override
  String get prayersToday => 'Today\'s prayers';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get quranWird => 'Qur\'an wird';

  @override
  String quranPages(int done, int goal) {
    return '$done of $goal pages';
  }

  @override
  String get charityGoal => 'Charity goal';

  @override
  String charityAmount(int done, int goal) {
    return '$done of $goal';
  }

  @override
  String get dhikrCounter => 'Dhikr counter';

  @override
  String get dhikrTapHint => 'Tap to count';

  @override
  String get dhikrReset => 'Reset';

  @override
  String get productivityHubTitle => 'Productivity Hub';

  @override
  String get topTasks => 'Top tasks';

  @override
  String get noTasks => 'All caught up. Enjoy the calm.';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get streakTitle => 'Streak';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String get streakKeepGrowing => 'Keep showing up — your tree grows with you.';

  @override
  String get morningBrief => 'Morning Brief';

  @override
  String get morningBriefSubtitle => 'Your day at a glance';

  @override
  String get morningBriefPrayers => 'Prayers';

  @override
  String get morningBriefWird => 'Qur\'an wird';

  @override
  String get morningBriefTasks => 'Top tasks';

  @override
  String get morningBriefPlay => 'Play brief (coming soon)';

  @override
  String get close => 'Close';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonBody => 'This part of Meezan is on the way.';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navQuran => 'Qur\'an';

  @override
  String get navCharity => 'Charity';

  @override
  String get navTasks => 'Tasks';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get toggleLanguage => 'Switch language';
}
