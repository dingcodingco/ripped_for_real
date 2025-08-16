// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RIPPED FOR REAL';

  @override
  String get home => 'Home';

  @override
  String get saved => 'Saved';

  @override
  String get savedQuotes => 'SAVED QUOTES';

  @override
  String get getTodaysQuote => 'GET TODAY\'S QUOTE';

  @override
  String get nextQuote => 'NEXT QUOTE';

  @override
  String get noSavedQuotes => 'No saved quotes yet';

  @override
  String get startSaving => 'Start saving your favorite motivation';

  @override
  String get holdUp => 'Hold Up';

  @override
  String get loadingMotivation =>
      'Loading your motivation fuel. Try again in a moment.\n\nFor now, here\'s a bonus quote without ads.';

  @override
  String get getFreeQuote => 'Get Free Quote';

  @override
  String get wait => 'Wait';

  @override
  String get gotIt => 'Got It';

  @override
  String get shareText => 'Stay hard! 💪 #RippedForReal';

  @override
  String get failedToShare => 'Failed to share quote';

  @override
  String get notificationTitle => 'Time to get after it!';

  @override
  String get notificationBody =>
      'Your daily dose of motivation awaits. Stay hard.';

  @override
  String get trackingUsageDescription =>
      'This app uses tracking to provide personalized ads and improve your experience.';

  @override
  String get photoLibraryAddUsageDescription =>
      'This app saves motivational quote images to your photo library when you share them.';

  @override
  String get photoLibraryUsageDescription =>
      'This app needs access to save motivational quotes as images.';

  @override
  String get categoryMindset => 'MINDSET';

  @override
  String get categoryMoney => 'MONEY';

  @override
  String get categoryStrength => 'STRENGTH';

  @override
  String get categoryDiscipline => 'DISCIPLINE';

  @override
  String get categorySuccess => 'SUCCESS';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days streak 🔥',
      one: '1 day streak 🔥',
      zero: 'Start your streak!',
    );
    return '$_temp0';
  }

  @override
  String level(int level) {
    return 'Level $level';
  }

  @override
  String xpPoints(int points) {
    return '$points XP';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get totalQuotesRead => 'Total Quotes Read';

  @override
  String get favoriteCategory => 'Favorite Category';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get filterByCategory => 'Filter by Category';

  @override
  String get allCategories => 'All Categories';
}
