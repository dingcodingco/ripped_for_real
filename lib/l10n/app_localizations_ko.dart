// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '진짜가 되라';

  @override
  String get home => '홈';

  @override
  String get saved => '저장됨';

  @override
  String get savedQuotes => '저장된 명언';

  @override
  String get getTodaysQuote => '오늘의 명언 받기';

  @override
  String get nextQuote => '다음 명언';

  @override
  String get noSavedQuotes => '저장된 명언이 없습니다';

  @override
  String get startSaving => '좋아하는 동기부여를 저장하세요';

  @override
  String get holdUp => '잠깐';

  @override
  String get loadingMotivation =>
      '동기부여 연료를 충전 중입니다. 잠시 후 다시 시도하세요.\n\n지금은 광고 없이 무료 명언을 드립니다.';

  @override
  String get getFreeQuote => '무료 명언 받기';

  @override
  String get wait => '기다리기';

  @override
  String get gotIt => '확인';

  @override
  String get shareText => '강해져라! 💪 #진짜가되라';

  @override
  String get failedToShare => '명언 공유 실패';

  @override
  String get notificationTitle => '시작할 시간이다!';

  @override
  String get notificationBody => '오늘의 동기부여가 기다리고 있습니다. 강해지세요.';

  @override
  String get trackingUsageDescription =>
      '이 앱은 맞춤형 광고 제공과 사용자 경험 개선을 위해 추적을 사용합니다.';

  @override
  String get photoLibraryAddUsageDescription =>
      '이 앱은 명언을 공유할 때 이미지로 사진 보관함에 저장합니다.';

  @override
  String get photoLibraryUsageDescription => '이 앱은 명언을 이미지로 저장하기 위해 접근이 필요합니다.';

  @override
  String get categoryMindset => '마인드셋';

  @override
  String get categoryMoney => '돈';

  @override
  String get categoryStrength => '힘';

  @override
  String get categoryDiscipline => '규율';

  @override
  String get categorySuccess => '성공';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 연속 🔥',
      one: '1일 연속 🔥',
      zero: '스트릭을 시작하세요!',
    );
    return '$_temp0';
  }

  @override
  String level(int level) {
    return '레벨 $level';
  }

  @override
  String xpPoints(int points) {
    return '$points XP';
  }

  @override
  String get statistics => '통계';

  @override
  String get totalQuotesRead => '읽은 명언 수';

  @override
  String get favoriteCategory => '선호 카테고리';

  @override
  String get currentStreak => '현재 스트릭';

  @override
  String get longestStreak => '최장 스트릭';

  @override
  String get filterByCategory => '카테고리 필터';

  @override
  String get allCategories => '모든 카테고리';
}
