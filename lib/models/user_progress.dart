class UserProgress {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastAccessDate;
  final int totalQuotesRead;
  final int level;
  final int xp;
  final Map<String, int> categoryReadCount;
  final List<DateTime> streakDates;

  UserProgress({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastAccessDate,
    this.totalQuotesRead = 0,
    this.level = 1,
    this.xp = 0,
    Map<String, int>? categoryReadCount,
    List<DateTime>? streakDates,
  }) : categoryReadCount = categoryReadCount ?? {},
        streakDates = streakDates ?? [];

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastAccessDate: json['lastAccessDate'] != null 
          ? DateTime.parse(json['lastAccessDate']) 
          : null,
      totalQuotesRead: json['totalQuotesRead'] ?? 0,
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      categoryReadCount: Map<String, int>.from(json['categoryReadCount'] ?? {}),
      streakDates: (json['streakDates'] as List<dynamic>?)
          ?.map((date) => DateTime.parse(date as String))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastAccessDate': lastAccessDate?.toIso8601String(),
      'totalQuotesRead': totalQuotesRead,
      'level': level,
      'xp': xp,
      'categoryReadCount': categoryReadCount,
      'streakDates': streakDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  UserProgress copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastAccessDate,
    int? totalQuotesRead,
    int? level,
    int? xp,
    Map<String, int>? categoryReadCount,
    List<DateTime>? streakDates,
  }) {
    return UserProgress(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastAccessDate: lastAccessDate ?? this.lastAccessDate,
      totalQuotesRead: totalQuotesRead ?? this.totalQuotesRead,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      categoryReadCount: categoryReadCount ?? this.categoryReadCount,
      streakDates: streakDates ?? this.streakDates,
    );
  }

  // Calculate level from XP (100 XP per level)
  static int calculateLevel(int xp) {
    return (xp ~/ 100) + 1;
  }

  // Get XP for current level progress
  int get currentLevelXP => xp % 100;

  // Get favorite category
  String? get favoriteCategory {
    if (categoryReadCount.isEmpty) return null;
    return categoryReadCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}