import 'package:hive/hive.dart';
import '../models/challenge_completion.dart';

class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  static const String _boxName = 'challenge_completions';
  
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  // Save challenge completion
  Future<void> saveChallengeCompletion(ChallengeCompletion completion) async {
    final box = Hive.box(_boxName);
    await box.put(completion.key, completion.toJson());
  }

  // Check if a specific quote's challenge is completed today
  bool isQuoteChallengeCompleted(int quoteId) {
    final box = Hive.box(_boxName);
    final today = DateTime.now();
    final key = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}-quote-$quoteId';
    return box.containsKey(key);
  }

  // Get challenge completion for a specific quote today
  ChallengeCompletion? getQuoteCompletion(int quoteId) {
    final box = Hive.box(_boxName);
    final today = DateTime.now();
    final key = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}-quote-$quoteId';
    
    final data = box.get(key);
    if (data != null) {
      return ChallengeCompletion.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  // Get all completions for today
  List<ChallengeCompletion> getTodaysCompletions() {
    final today = DateTime.now();
    return getAllCompletions().where((completion) {
      return completion.completedDate.year == today.year &&
             completion.completedDate.month == today.month &&
             completion.completedDate.day == today.day;
    }).toList();
  }

  // Count today's completed challenges
  int getTodaysCompletedCount() {
    return getTodaysCompletions().length;
  }

  // Get all completions (for history/stats)
  List<ChallengeCompletion> getAllCompletions() {
    final box = Hive.box(_boxName);
    final completions = <ChallengeCompletion>[];
    
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        completions.add(ChallengeCompletion.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    
    completions.sort((a, b) => b.completedDate.compareTo(a.completedDate));
    return completions;
  }

  // Get completions for a specific month
  List<ChallengeCompletion> getCompletionsForMonth(int year, int month) {
    return getAllCompletions().where((completion) {
      return completion.completedDate.year == year && 
             completion.completedDate.month == month;
    }).toList();
  }

  // Clear all completions (for testing)
  Future<void> clearAllCompletions() async {
    final box = Hive.box(_boxName);
    await box.clear();
  }
}