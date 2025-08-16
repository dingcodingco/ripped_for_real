import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('en'),
    Locale('ko'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'RIPPED FOR REAL'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @savedQuotes.
  ///
  /// In en, this message translates to:
  /// **'SAVED QUOTES'**
  String get savedQuotes;

  /// No description provided for @getTodaysQuote.
  ///
  /// In en, this message translates to:
  /// **'GET TODAY\'S QUOTE'**
  String get getTodaysQuote;

  /// No description provided for @nextQuote.
  ///
  /// In en, this message translates to:
  /// **'NEXT QUOTE'**
  String get nextQuote;

  /// No description provided for @noSavedQuotes.
  ///
  /// In en, this message translates to:
  /// **'No saved quotes yet'**
  String get noSavedQuotes;

  /// No description provided for @startSaving.
  ///
  /// In en, this message translates to:
  /// **'Start saving your favorite motivation'**
  String get startSaving;

  /// No description provided for @holdUp.
  ///
  /// In en, this message translates to:
  /// **'Hold Up'**
  String get holdUp;

  /// No description provided for @loadingMotivation.
  ///
  /// In en, this message translates to:
  /// **'Loading your motivation fuel. Try again in a moment.\n\nFor now, here\'s a bonus quote without ads.'**
  String get loadingMotivation;

  /// No description provided for @getFreeQuote.
  ///
  /// In en, this message translates to:
  /// **'Get Free Quote'**
  String get getFreeQuote;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get wait;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Stay hard! 💪 #RippedForReal'**
  String get shareText;

  /// No description provided for @failedToShare.
  ///
  /// In en, this message translates to:
  /// **'Failed to share quote'**
  String get failedToShare;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to get after it!'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your daily dose of motivation awaits. Stay hard.'**
  String get notificationBody;

  /// No description provided for @trackingUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'This app uses tracking to provide personalized ads and improve your experience.'**
  String get trackingUsageDescription;

  /// No description provided for @photoLibraryAddUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'This app saves motivational quote images to your photo library when you share them.'**
  String get photoLibraryAddUsageDescription;

  /// No description provided for @photoLibraryUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'This app needs access to save motivational quotes as images.'**
  String get photoLibraryUsageDescription;

  /// No description provided for @categoryMindset.
  ///
  /// In en, this message translates to:
  /// **'MINDSET'**
  String get categoryMindset;

  /// No description provided for @categoryMoney.
  ///
  /// In en, this message translates to:
  /// **'MONEY'**
  String get categoryMoney;

  /// No description provided for @categoryStrength.
  ///
  /// In en, this message translates to:
  /// **'STRENGTH'**
  String get categoryStrength;

  /// No description provided for @categoryDiscipline.
  ///
  /// In en, this message translates to:
  /// **'DISCIPLINE'**
  String get categoryDiscipline;

  /// No description provided for @categorySuccess.
  ///
  /// In en, this message translates to:
  /// **'SUCCESS'**
  String get categorySuccess;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Start your streak!} =1{1 day streak 🔥} other{{count} days streak 🔥}}'**
  String streakDays(int count);

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(int level);

  /// No description provided for @xpPoints.
  ///
  /// In en, this message translates to:
  /// **'{points} XP'**
  String xpPoints(int points);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalQuotesRead.
  ///
  /// In en, this message translates to:
  /// **'Total Quotes Read'**
  String get totalQuotesRead;

  /// No description provided for @favoriteCategory.
  ///
  /// In en, this message translates to:
  /// **'Favorite Category'**
  String get favoriteCategory;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
