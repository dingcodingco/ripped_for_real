import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/quote.dart';
import '../models/user_progress.dart';
import '../services/quote_service.dart';
import '../services/ad_service.dart';
import '../services/progress_service.dart';
import '../services/challenge_service.dart';
import '../models/challenge_completion.dart';
import '../widgets/achievement_popup.dart';
import '../widgets/challenge_completion_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:io' show Platform;

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> 
    with SingleTickerProviderStateMixin {
  final QuoteService _quoteService = QuoteService();
  final AdService _adService = AdService();
  final ProgressService _progressService = ProgressService();
  final ChallengeService _challengeService = ChallengeService();
  final ScreenshotController _screenshotController = ScreenshotController();
  
  Quote? _currentQuote;
  UserProgress _userProgress = UserProgress();
  bool _isLoading = true;
  ChallengeCompletion? _currentQuoteCompletion;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _quotesViewedToday = 0;
  String? _selectedCategory;
  
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _quoteService.loadQuotes();
    _loadBannerAd();
    _adService.loadInterstitialAd();
    _adService.loadRewardedAd();
    
    // Set up achievement callback
    _progressService.setAchievementCallback((title, message, icon, color) {
      if (mounted) {
        AchievementPopup.show(
          context,
          title: title,
          message: message,
          icon: icon,
          color: color,
        );
      }
    });
    
    // Check and update streak
    _userProgress = await _progressService.checkAndUpdateStreak();
    
    // Load daily quote
    final dailyQuote = _quoteService.getDailyQuote();
    if (dailyQuote != null) {
      // Check if this quote's challenge is completed
      _currentQuoteCompletion = _challengeService.getQuoteCompletion(dailyQuote.id);
      
      setState(() {
        _currentQuote = dailyQuote;
        _isLoading = false;
        _quotesViewedToday = 1; // Count the initial daily quote
      });
      _animationController.forward();
      
      // Add XP for daily visit
      _userProgress = await _progressService.addQuoteRead(dailyQuote.category);
      setState(() {});
    }
  }

  void _loadBannerAd() {
    // Skip banner ad loading for iOS
    if (Platform.isIOS) return;
    
    try {
      _bannerAd = _adService.createBannerAd()..load();
    } catch (e) {
      // Ads disabled for iOS
      _bannerAd = null;
    }
  }

  String _getQuoteChallenge(Quote quote) {
    // Generate challenge based on quote category
    switch (quote.category) {
      case 'mindset':
        return '🧠 Write down 3 things you\'re grateful for';
      case 'money':
        return '💰 Save \$10 today or skip one unnecessary purchase';
      case 'strength':
        return '💪 Do 20 push-ups or 5 minute workout';
      case 'discipline':
        return '⏰ Wake up 30 minutes earlier tomorrow';
      case 'success':
        return '📈 Complete your most important task first';
      default:
        return '✅ Take one action towards your goal';
    }
  }

  Future<void> _completeChallenge() async {
    if (_currentQuote == null) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChallengeCompletionDialog(
        challengeType: _currentQuote!.category,
        onComplete: (data) async {
          // Save challenge completion for this specific quote
          final now = DateTime.now();
          final completion = ChallengeCompletion(
            completedDate: DateTime(now.year, now.month, now.day),
            challengeType: _currentQuote!.category,
            responseText: data['text'] ?? '',
            imagePath: data['image'],
            timestamp: now,
            quoteId: _currentQuote!.id,
          );
          
          await _challengeService.saveChallengeCompletion(completion);
          
          setState(() {
            _currentQuoteCompletion = completion;
          });
          
          // Add bonus XP for completing challenge
          _userProgress = await _progressService.addQuoteShared(); // Using share XP as bonus
          setState(() {});
          
          // Show achievement
          if (mounted) {
            AchievementPopup.show(
              context,
              title: 'Challenge Completed!',
              message: '+50 XP earned',
              icon: Icons.check_circle,
              color: Colors.green,
            );
          }
        },
      ),
    );
  }

  Future<void> _shareProgress() async {
    try {
      final image = await _screenshotController.captureFromWidget(
        _buildShareCard(),
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/progress_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Day ${_userProgress.currentStreak} of becoming RIPPED FOR REAL 💪 #RippedForReal #SelfImprovement',
      );
      
      // Add XP for sharing
      _userProgress = await _progressService.addQuoteShared();
      setState(() {});
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  bool _shouldShowAd() {
    // Show ad after every 3 quotes (starting from the 4th quote)
    return _quotesViewedToday > 0 && _quotesViewedToday % 3 == 0;
  }

  Future<void> _handleNextQuote() async {
    if (_shouldShowAd()) {
      await _showRewardedAdForNextQuote();
    } else {
      await _showNextQuote();
    }
  }

  Future<void> _showNextQuote() async {
    // Get a new random quote with selected category
    final newQuote = _quoteService.getRandomQuote(category: _selectedCategory);
    
    // Check if this quote's challenge is completed
    final quoteCompletion = _challengeService.getQuoteCompletion(newQuote.id);
    
    // Update the UI with the new quote
    setState(() {
      _currentQuote = newQuote;
      _currentQuoteCompletion = quoteCompletion;
      _quotesViewedToday++;
    });
    
    // Restart the fade animation
    _animationController.reset();
    _animationController.forward();
    
    // Add XP for viewing the quote
    _userProgress = await _progressService.addQuoteRead(newQuote.category);
    setState(() {});
    
    // Show success message for free quotes
    if (mounted) {
      AchievementPopup.show(
        context,
        title: 'New Quote!',
        message: '+10 XP earned',
        icon: Icons.auto_awesome,
        color: Colors.blue,
      );
    }
  }

  Future<void> _showRewardedAdForNextQuote() async {
    if (!_adService.isRewardedAdReady) {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            backgroundColor: Colors.grey,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Loading ad...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
      
      // Try to load the ad
      _adService.loadRewardedAd();
      
      // Wait a bit for the ad to load
      await Future.delayed(const Duration(seconds: 3));
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Check again if ad is ready
      if (!_adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ad not available. Try again in a moment.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    // Show the rewarded ad
    _adService.showRewardedAd(
      onRewarded: () async {
        // Get a new random quote with selected category
        final newQuote = _quoteService.getRandomQuote(category: _selectedCategory);
        
        // Check if this quote's challenge is completed
        final quoteCompletion = _challengeService.getQuoteCompletion(newQuote.id);
        
        // Update the UI with the new quote
        setState(() {
          _currentQuote = newQuote;
          _currentQuoteCompletion = quoteCompletion;
          _quotesViewedToday++;
        });
        
        // Restart the fade animation
        _animationController.reset();
        _animationController.forward();
        
        // Add XP for viewing the ad
        _userProgress = await _progressService.addQuoteRead(newQuote.category);
        setState(() {});
        
        // Show success message
        if (mounted) {
          AchievementPopup.show(
            context,
            title: 'New Quote Unlocked!',
            message: '+10 XP earned',
            icon: Icons.auto_awesome,
            color: Colors.orange,
          );
        }
        
        // Load a new ad for next time
        _adService.loadRewardedAd();
      },
    );
  }

  Widget _buildShareCard() {
    return Container(
      width: 1080,
      height: 1920,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF1a1a1a)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'RIPPED FOR REAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(60),
            child: Column(
              children: [
                Text(
                  'DAY ${_userProgress.currentStreak}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 40),
                if (_currentQuote != null)
                  Text(
                    '"${_currentQuote!.text}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShareStat('LEVEL', '${_userProgress.level}'),
                    const SizedBox(width: 30),
                    _buildShareStat('STREAK', '${_userProgress.currentStreak}'),
                    const SizedBox(width: 30),
                    _buildShareStat('XP', '${_userProgress.xp}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'id': null, 'name': 'ALL', 'icon': Icons.apps},
      {'id': 'mindset', 'name': 'MINDSET', 'icon': Icons.psychology},
      {'id': 'money', 'name': 'MONEY', 'icon': Icons.attach_money},
      {'id': 'strength', 'name': 'STRENGTH', 'icon': Icons.fitness_center},
      {'id': 'discipline', 'name': 'DISCIPLINE', 'icon': Icons.timer},
      {'id': 'success', 'name': 'SUCCESS', 'icon': Icons.trending_up},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];
          
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == categories.length - 1 ? 0 : 4,
            ),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.grey[800],
              selectedColor: Colors.white,
              checkmarkColor: Colors.black,
              onSelected: (selected) async {
                setState(() {
                  _selectedCategory = selected ? category['id'] as String? : null;
                });
                
                // Get a new quote from the selected category
                final newQuote = _quoteService.getRandomQuote(category: _selectedCategory);
                
                // Check if this quote's challenge is completed
                final quoteCompletion = _challengeService.getQuoteCompletion(newQuote.id);
                
                // Update the UI with the new quote
                setState(() {
                  _currentQuote = newQuote;
                  _currentQuoteCompletion = quoteCompletion;
                  // Don't increment quotesViewedToday when just filtering
                });
                
                // Restart the fade animation
                _animationController.reset();
                _animationController.forward();
                
                // Show feedback
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _selectedCategory == null 
                            ? 'Showing all categories' 
                            : 'Showing ${category['name']} quotes',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.grey[800],
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                children: [
                  // Header with streak
                  _buildHeader(),
                  
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Combined Quote and Challenge Card
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildQuoteWithChallengeCard(),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Action Buttons
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Banner Ad
                  if (_bannerAd != null)
                    Container(
                      alignment: Alignment.center,
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section with title and streak
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RIPPED FOR REAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${_userProgress.level} • ${_userProgress.xp} XP',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _userProgress.currentStreak > 0 
                        ? Colors.orange 
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_userProgress.currentStreak}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Category filter
          _buildCategoryFilter(),
        ],
      ),
    );
  }

  Widget _buildQuoteWithChallengeCard() {
    if (_currentQuote == null) return const SizedBox();
    
    // Check if this specific quote's challenge is completed
    final isQuoteChallengeCompleted = _currentQuoteCompletion != null;
    final challenge = _getQuoteChallenge(_currentQuote!);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Quote Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _quotesViewedToday == 1 ? 'TODAY\'S MOTIVATION' : 'MOTIVATION #$_quotesViewedToday',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _currentQuote!.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(_currentQuote!.category).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCategoryColor(_currentQuote!.category).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(_currentQuote!.category),
                            size: 14,
                            color: _getCategoryColor(_currentQuote!.category),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currentQuote!.category.toUpperCase(),
                            style: TextStyle(
                              color: _getCategoryColor(_currentQuote!.category),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedCategory != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'FILTERED',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey[800],
          ),
          
          // Challenge Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isQuoteChallengeCompleted
                  ? Colors.green.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isQuoteChallengeCompleted
                          ? Icons.check_circle
                          : Icons.flag,
                      color: isQuoteChallengeCompleted
                          ? Colors.green
                          : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CHALLENGE',
                      style: TextStyle(
                        color: isQuoteChallengeCompleted
                            ? Colors.green
                            : Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  challenge,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: isQuoteChallengeCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (!isQuoteChallengeCompleted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _completeChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'COMPLETE CHALLENGE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ] else if (isQuoteChallengeCompleted) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.green[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Challenge completed! +50 XP',
                        style: TextStyle(
                          color: Colors.green[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (_currentQuoteCompletion != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your response:',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentQuoteCompletion!.responseText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  Color _getCategoryColor(String category) {
    switch (category) {
      case 'mindset':
        return Colors.purple;
      case 'money':
        return Colors.green;
      case 'strength':
        return Colors.orange;
      case 'discipline':
        return Colors.blue;
      case 'success':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'mindset':
        return Icons.psychology;
      case 'money':
        return Icons.attach_money;
      case 'strength':
        return Icons.fitness_center;
      case 'discipline':
        return Icons.timer;
      case 'success':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save and Share buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    _quoteService.toggleFavorite(_currentQuote!);
                  });
                  _userProgress = await _progressService.addQuoteSaved();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  _currentQuote != null && _quoteService.isFavorite(_currentQuote!.id) 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  color: _currentQuote != null && _quoteService.isFavorite(_currentQuote!.id) 
                      ? Colors.red 
                      : Colors.white,
                ),
                label: const Text('SAVE'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareProgress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.share),
                label: const Text('SHARE'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Next Quote button (free or with ad)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleNextQuote,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(_shouldShowAd() ? Icons.play_circle_fill : Icons.arrow_forward),
            label: Text(
              _shouldShowAd() ? 'WATCH AD FOR NEXT QUOTE' : 'NEXT QUOTE (${3 - (_quotesViewedToday % 3)}/3 FREE)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}