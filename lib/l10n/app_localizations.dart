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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Meezan'**
  String get appName;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Meezan'**
  String get dashboardTitle;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @balanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Life Balance'**
  String get balanceTitle;

  /// No description provided for @balanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your worship and worldly life, in harmony'**
  String get balanceSubtitle;

  /// No description provided for @ringSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get ringSpiritual;

  /// No description provided for @ringWorldly.
  ///
  /// In en, this message translates to:
  /// **'Worldly'**
  String get ringWorldly;

  /// No description provided for @spiritualHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Hub'**
  String get spiritualHubTitle;

  /// No description provided for @prayersToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayers'**
  String get prayersToday;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @quranWird.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an wird'**
  String get quranWird;

  /// No description provided for @quranPages.
  ///
  /// In en, this message translates to:
  /// **'{done} of {goal} pages'**
  String quranPages(int done, int goal);

  /// No description provided for @charityGoal.
  ///
  /// In en, this message translates to:
  /// **'Charity goal'**
  String get charityGoal;

  /// No description provided for @charityAmount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {goal}'**
  String charityAmount(int done, int goal);

  /// No description provided for @dhikrCounter.
  ///
  /// In en, this message translates to:
  /// **'Dhikr counter'**
  String get dhikrCounter;

  /// No description provided for @dhikrTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get dhikrTapHint;

  /// No description provided for @dhikrReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get dhikrReset;

  /// No description provided for @productivityHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Productivity Hub'**
  String get productivityHubTitle;

  /// No description provided for @topTasks.
  ///
  /// In en, this message translates to:
  /// **'Top tasks'**
  String get topTasks;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'All caught up. Enjoy the calm.'**
  String get noTasks;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskCompleted;

  /// No description provided for @streakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakTitle;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak yet} =1{1 day} other{{count} days}}'**
  String streakDays(int count);

  /// No description provided for @streakKeepGrowing.
  ///
  /// In en, this message translates to:
  /// **'Keep showing up — your tree grows with you.'**
  String get streakKeepGrowing;

  /// No description provided for @morningBrief.
  ///
  /// In en, this message translates to:
  /// **'Morning Brief'**
  String get morningBrief;

  /// No description provided for @morningBriefSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your day at a glance'**
  String get morningBriefSubtitle;

  /// No description provided for @morningBriefPrayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get morningBriefPrayers;

  /// No description provided for @morningBriefWird.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an wird'**
  String get morningBriefWird;

  /// No description provided for @morningBriefTasks.
  ///
  /// In en, this message translates to:
  /// **'Top tasks'**
  String get morningBriefTasks;

  /// No description provided for @morningBriefPlay.
  ///
  /// In en, this message translates to:
  /// **'Play brief (coming soon)'**
  String get morningBriefPlay;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This part of Meezan is on the way.'**
  String get comingSoonBody;

  /// No description provided for @navPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get navPrayer;

  /// No description provided for @navQuran.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an'**
  String get navQuran;

  /// No description provided for @navCharity.
  ///
  /// In en, this message translates to:
  /// **'Charity'**
  String get navCharity;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// No description provided for @toggleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get toggleLanguage;
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
