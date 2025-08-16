import 'package:flutter/material.dart';
import '../models/user_progress.dart';

class ProgressHeader extends StatelessWidget {
  final UserProgress progress;

  const ProgressHeader({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStreakCard(),
              _buildLevelCard(),
              _buildXPCard(),
            ],
          ),
          if (progress.currentStreak > 0)
            const SizedBox(height: 12),
          if (progress.currentStreak > 0)
            _buildStreakCalendar(),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: progress.currentStreak > 0 ? Colors.orange : Colors.grey[800]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔥',
              style: TextStyle(
                fontSize: progress.currentStreak > 0 ? 24 : 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${progress.currentStreak}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Day Streak',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.military_tech,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              'Level ${progress.level}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _getLevelTitle(progress.level),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXPCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bolt,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              '${progress.currentLevelXP}/100',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'XP',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCalendar() {
    final streakEmojis = List.generate(
      progress.currentStreak.clamp(0, 7),
      (index) => '🔥',
    ).join(' ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            streakEmojis,
            style: const TextStyle(fontSize: 20),
          ),
          if (progress.currentStreak >= 7)
            const SizedBox(height: 4),
          if (progress.currentStreak >= 7)
            Text(
              progress.currentStreak >= 30 
                  ? '🏆 LEGEND STATUS! 🏆' 
                  : progress.currentStreak >= 21 
                      ? '💪 21 Day Warrior!' 
                      : '⭐ Week Champion!',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level >= 30) return 'Legend';
    if (level >= 20) return 'Champion';
    if (level >= 10) return 'Warrior';
    return 'Rookie';
  }
}