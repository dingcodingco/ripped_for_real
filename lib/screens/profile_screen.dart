import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../models/challenge_completion.dart';
import '../services/progress_service.dart';
import '../services/challenge_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProgressService _progressService = ProgressService();
  final ChallengeService _challengeService = ChallengeService();
  late UserProgress _userProgress;
  List<ChallengeCompletion> _challengeCompletions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  Future<void> _loadUserProgress() async {
    _userProgress = _progressService.getProgress();
    
    // Load challenge completions for current month
    final now = DateTime.now();
    _challengeCompletions = _challengeService.getCompletionsForMonth(now.year, now.month);
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Responsive design for iPad
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final contentPadding = isTablet ? 40.0 : 20.0;
    final maxContentWidth = isTablet ? 600.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'MY PROGRESS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: isTablet ? 28 : 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(),
                  SizedBox(height: isTablet ? 32 : 24),
                  
                  // Stats Grid
                  _buildStatsGrid(),
                  SizedBox(height: isTablet ? 32 : 24),
                  
                  // Streak Calendar
                  _buildStreakCalendar(),
                  SizedBox(height: isTablet ? 32 : 24),
                  
                  // Category Breakdown
                  _buildCategoryBreakdown(),
                  SizedBox(height: isTablet ? 32 : 24),
                  
                  // Achievements
                  _buildAchievements(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final levelColor = _getLevelColor(_userProgress.level);
    final levelTitle = _getLevelTitle(_userProgress.level);
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            levelColor.withValues(alpha: 0.3),
            levelColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(
          color: levelColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Level Badge
          Container(
            width: isTablet ? 140 : 100,
            height: isTablet ? 140 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  levelColor,
                  levelColor.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: levelColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.military_tech,
                    color: Colors.white,
                    size: isTablet ? 56 : 40,
                  ),
                  Text(
                    '${_userProgress.level}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 32 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            levelTitle.toUpperCase(),
            style: TextStyle(
              color: levelColor,
              fontSize: isTablet ? 32 : 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_userProgress.xp} TOTAL XP',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: isTablet ? 18 : 14,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          // XP Progress Bar
          Container(
            height: isTablet ? 12 : 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _userProgress.currentLevelXP / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: levelColor,
                  borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_userProgress.currentLevelXP}/100 XP to Level ${_userProgress.level + 1}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTablet ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: isTablet ? 16 : 12,
      crossAxisSpacing: isTablet ? 16 : 12,
      childAspectRatio: isTablet ? 1.5 : 1.3,
      children: [
        _buildStatCard(
          icon: Icons.local_fire_department,
          title: 'Current Streak',
          value: '${_userProgress.currentStreak}',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.emoji_events,
          title: 'Longest Streak',
          value: '${_userProgress.longestStreak}',
          color: Colors.amber,
        ),
        _buildStatCard(
          icon: Icons.format_quote,
          title: 'Quotes Read',
          value: '${_userProgress.totalQuotesRead}',
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.category,
          title: 'Favorite Category',
          value: _userProgress.favoriteCategory?.toUpperCase() ?? 'NONE',
          color: Colors.purple,
          isSmallText: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isSmallText = false,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: isTablet ? 32 : 20,
          ),
          SizedBox(height: isTablet ? 8 : 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallText ? (isTablet ? 20 : 14) : (isTablet ? 28 : 20),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isTablet ? 14 : 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Colors.grey[400],
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'STREAK CALENDAR',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: isTablet ? 18 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: isTablet ? 12 : 8,
              crossAxisSpacing: isTablet ? 12 : 8,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(now.year, now.month, day);
              final isToday = date.day == now.day;
              final hasStreak = _userProgress.streakDates.any((d) => 
                d.year == date.year && 
                d.month == date.month && 
                d.day == date.day
              );
              
              final hasChallengeCompletion = _challengeCompletions.any((c) =>
                c.completedDate.year == date.year &&
                c.completedDate.month == date.month &&
                c.completedDate.day == date.day
              );
              
              return Container(
                decoration: BoxDecoration(
                  color: hasStreak 
                      ? Colors.orange.withValues(alpha: 0.3)
                      : Colors.grey[850],
                  borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                  border: Border.all(
                    color: isToday 
                        ? Colors.orange 
                        : hasStreak 
                            ? Colors.orange.withValues(alpha: 0.5)
                            : Colors.grey[800]!,
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: hasStreak ? Colors.orange : Colors.grey[600],
                          fontSize: isTablet ? 16 : 12,
                          fontWeight: hasStreak ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (hasChallengeCompletion)
                      Positioned(
                        top: isTablet ? 4 : 2,
                        right: isTablet ? 4 : 2,
                        child: Container(
                          width: isTablet ? 8 : 6,
                          height: isTablet ? 8 : 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final categories = _userProgress.categoryReadCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (categories.isEmpty) {
      return const SizedBox();
    }
    
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: Colors.grey[400],
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'CATEGORY BREAKDOWN',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: isTablet ? 18 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          ...categories.map((entry) {
            final percentage = (entry.value / _userProgress.totalQuotesRead * 100).round();
            return Padding(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 6 : 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: isTablet ? 16 : 12,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value} ($percentage%)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      if (_userProgress.currentStreak >= 7)
        _buildAchievementItem(
          icon: Icons.local_fire_department,
          title: 'Week Warrior',
          description: '7 day streak',
          color: Colors.orange,
          unlocked: true,
        ),
      if (_userProgress.currentStreak >= 21)
        _buildAchievementItem(
          icon: Icons.emoji_events,
          title: '21 Day Champion',
          description: 'Built a habit',
          color: Colors.purple,
          unlocked: true,
        ),
      if (_userProgress.currentStreak >= 30)
        _buildAchievementItem(
          icon: Icons.diamond,
          title: 'Legendary Status',
          description: '30 day streak',
          color: Colors.amber,
          unlocked: true,
        ),
      if (_userProgress.level >= 10)
        _buildAchievementItem(
          icon: Icons.shield,
          title: 'Warrior',
          description: 'Reached level 10',
          color: Colors.blue,
          unlocked: true,
        ),
      if (_userProgress.level >= 20)
        _buildAchievementItem(
          icon: Icons.military_tech,
          title: 'Champion',
          description: 'Reached level 20',
          color: Colors.purple,
          unlocked: true,
        ),
      if (_userProgress.level >= 30)
        _buildAchievementItem(
          icon: Icons.star,
          title: 'Legend',
          description: 'Reached level 30',
          color: Colors.amber,
          unlocked: true,
        ),
    ];
    
    if (achievements.isEmpty) {
      return const SizedBox();
    }
    
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.grey[400],
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'ACHIEVEMENTS',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: isTablet ? 18 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          ...achievements,
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool unlocked,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: unlocked 
            ? color.withValues(alpha: 0.1)
            : Colors.grey[850],
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: unlocked 
              ? color.withValues(alpha: 0.5)
              : Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: unlocked ? color : Colors.grey[700],
            size: isTablet ? 40 : 32,
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.grey[600],
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: unlocked ? Colors.grey[400] : Colors.grey[700],
                    fontSize: isTablet ? 16 : 12,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            Icon(
              Icons.check_circle,
              color: color,
              size: isTablet ? 28 : 24,
            ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 30) return Colors.amber;
    if (level >= 20) return Colors.purple;
    if (level >= 10) return Colors.blue;
    return Colors.green;
  }

  String _getLevelTitle(int level) {
    if (level >= 30) return 'Legend';
    if (level >= 20) return 'Champion';
    if (level >= 10) return 'Warrior';
    return 'Rookie';
  }
}