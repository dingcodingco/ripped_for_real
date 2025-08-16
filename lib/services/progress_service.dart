import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_progress.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static const String _boxName = 'user_progress';
  static const String _progressKey = 'progress';

  // XP rewards
  static const int xpForReading = 10;
  static const int xpForSaving = 20;
  static const int xpForSharing = 50;
  static const int xpForDailyStreak = 100;

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  UserProgress getProgress() {
    final box = Hive.box(_boxName);
    final json = box.get(_progressKey);
    if (json == null) {
      return UserProgress();
    }
    return UserProgress.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> saveProgress(UserProgress progress) async {
    final box = Hive.box(_boxName);
    await box.put(_progressKey, progress.toJson());
  }

  Future<UserProgress> checkAndUpdateStreak() async {
    var progress = getProgress();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Store previous values for achievement checking
    final previousStreak = progress.currentStreak;
    final previousLevel = progress.level;

    if (progress.lastAccessDate == null) {
      // First time user
      progress = progress.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastAccessDate: today,
        streakDates: [today],
        xp: progress.xp + xpForDailyStreak,
      );
    } else {
      final lastAccess = DateTime(
        progress.lastAccessDate!.year,
        progress.lastAccessDate!.month,
        progress.lastAccessDate!.day,
      );

      final daysDifference = today.difference(lastAccess).inDays;

      if (daysDifference == 0) {
        // Already accessed today, no streak update needed
        return progress;
      } else if (daysDifference == 1) {
        // Consecutive day! Streak continues
        final newStreak = progress.currentStreak + 1;
        final newLongestStreak = newStreak > progress.longestStreak 
            ? newStreak 
            : progress.longestStreak;
        
        final newStreakDates = [...progress.streakDates, today];
        
        progress = progress.copyWith(
          currentStreak: newStreak,
          longestStreak: newLongestStreak,
          lastAccessDate: today,
          streakDates: newStreakDates,
          xp: progress.xp + xpForDailyStreak,
        );
      } else {
        // Streak broken
        progress = progress.copyWith(
          currentStreak: 1,
          lastAccessDate: today,
          streakDates: [today],
          xp: progress.xp + xpForDailyStreak,
        );
      }
    }

    // Update level based on XP
    final newLevel = UserProgress.calculateLevel(progress.xp);
    if (newLevel != progress.level) {
      progress = progress.copyWith(level: newLevel);
    }

    await saveProgress(progress);
    
    // Check for achievements
    _checkAchievements(progress, previousStreak, previousLevel);
    
    return progress;
  }
  
  void _checkAchievements(UserProgress progress, int previousStreak, int previousLevel) {
    // Streak achievements
    if (progress.currentStreak == 7 && previousStreak < 7) {
      _achievementCallback?.call(
        'Week Warrior!',
        '7 day streak achieved',
        Icons.local_fire_department,
        Colors.orange,
      );
    } else if (progress.currentStreak == 21 && previousStreak < 21) {
      _achievementCallback?.call(
        '21 Day Champion!',
        'You built a habit!',
        Icons.emoji_events,
        Colors.purple,
      );
    } else if (progress.currentStreak == 30 && previousStreak < 30) {
      _achievementCallback?.call(
        'Legendary Status!',
        '30 day streak - unstoppable!',
        Icons.diamond,
        Colors.amber,
      );
    }
    
    // Level achievements
    if (progress.level > previousLevel) {
      if (progress.level == 10) {
        _achievementCallback?.call(
          'Warrior Unlocked!',
          'Level 10 reached',
          Icons.shield,
          Colors.blue,
        );
      } else if (progress.level == 20) {
        _achievementCallback?.call(
          'Champion Status!',
          'Level 20 achieved',
          Icons.military_tech,
          Colors.purple,
        );
      } else if (progress.level == 30) {
        _achievementCallback?.call(
          'LEGEND!',
          'Maximum level reached',
          Icons.star,
          Colors.amber,
        );
      }
    }
  }
  
  // Achievement callback
  Function(String title, String message, IconData icon, Color color)? _achievementCallback;
  
  void setAchievementCallback(Function(String, String, IconData, Color) callback) {
    _achievementCallback = callback;
  }
  
  void _checkLevelAchievement(int newLevel, int previousLevel) {
    if (newLevel > previousLevel) {
      if (newLevel == 10) {
        _achievementCallback?.call(
          'Warrior Unlocked!',
          'Level 10 reached',
          Icons.shield,
          Colors.blue,
        );
      } else if (newLevel == 20) {
        _achievementCallback?.call(
          'Champion Status!',
          'Level 20 achieved',
          Icons.military_tech,
          Colors.purple,
        );
      } else if (newLevel == 30) {
        _achievementCallback?.call(
          'LEGEND!',
          'Maximum level reached',
          Icons.star,
          Colors.amber,
        );
      } else if (newLevel % 5 == 0) {
        // Achievement for every 5 levels
        _achievementCallback?.call(
          'Level $newLevel!',
          'Keep grinding!',
          Icons.trending_up,
          Colors.green,
        );
      }
    }
  }

  Future<UserProgress> addQuoteRead(String category) async {
    var progress = getProgress();
    final previousLevel = progress.level;
    
    // Update total quotes read
    progress = progress.copyWith(
      totalQuotesRead: progress.totalQuotesRead + 1,
      xp: progress.xp + xpForReading,
    );

    // Update category count
    final categoryCount = Map<String, int>.from(progress.categoryReadCount);
    categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    progress = progress.copyWith(categoryReadCount: categoryCount);

    // Update level if needed
    final newLevel = UserProgress.calculateLevel(progress.xp);
    if (newLevel != progress.level) {
      progress = progress.copyWith(level: newLevel);
      _checkLevelAchievement(newLevel, previousLevel);
    }

    await saveProgress(progress);
    return progress;
  }

  Future<UserProgress> addQuoteSaved() async {
    var progress = getProgress();
    final previousLevel = progress.level;
    progress = progress.copyWith(xp: progress.xp + xpForSaving);

    // Update level if needed
    final newLevel = UserProgress.calculateLevel(progress.xp);
    if (newLevel != progress.level) {
      progress = progress.copyWith(level: newLevel);
      _checkLevelAchievement(newLevel, previousLevel);
    }

    await saveProgress(progress);
    return progress;
  }

  Future<UserProgress> addQuoteShared() async {
    var progress = getProgress();
    final previousLevel = progress.level;
    progress = progress.copyWith(xp: progress.xp + xpForSharing);

    // Update level if needed
    final newLevel = UserProgress.calculateLevel(progress.xp);
    if (newLevel != progress.level) {
      progress = progress.copyWith(level: newLevel);
      _checkLevelAchievement(newLevel, previousLevel);
    }

    await saveProgress(progress);
    return progress;
  }

  // Check if user has special achievements
  bool hasWeekStreak(UserProgress progress) => progress.currentStreak >= 7;
  bool hasMonthStreak(UserProgress progress) => progress.currentStreak >= 30;
  bool isRookie(UserProgress progress) => progress.level >= 1 && progress.level < 10;
  bool isWarrior(UserProgress progress) => progress.level >= 10 && progress.level < 20;
  bool isChampion(UserProgress progress) => progress.level >= 20 && progress.level < 30;
  bool isLegend(UserProgress progress) => progress.level >= 30;
}