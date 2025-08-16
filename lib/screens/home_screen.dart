import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;
import '../models/quote.dart';
import '../models/user_progress.dart';
import '../services/quote_service.dart';
import '../services/ad_service.dart';
import '../services/progress_service.dart';
import '../widgets/quote_card.dart';
import '../widgets/progress_header.dart';
import '../widgets/category_filter.dart';
import '../widgets/animated_background.dart';
import '../widgets/level_progress_widget.dart';
import '../widgets/achievement_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuoteService _quoteService = QuoteService();
  final AdService _adService = AdService();
  final ProgressService _progressService = ProgressService();
  Quote? _currentQuote;
  BannerAd? _bannerAd;
  bool _isLoading = true;
  int _quotesViewedToday = 0;
  bool _hasSeenDailyQuote = false;
  UserProgress _userProgress = UserProgress();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
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
    
    _loadDailyQuote();
    setState(() {
      _isLoading = false;
    });
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

  void _loadDailyQuote() async {
    final dailyQuote = _quoteService.getDailyQuote();
    setState(() {
      _currentQuote = dailyQuote;
      _hasSeenDailyQuote = true;
    });
    
    // Add XP for reading
    if (dailyQuote != null) {
      _userProgress = await _progressService.addQuoteRead(dailyQuote.category);
      setState(() {});
    }
  }

  void _loadNextQuote() {
    if (!_hasSeenDailyQuote) {
      _loadDailyQuote();
      return;
    }

    // Show rewarded ad after the free daily quote
    if (_quotesViewedToday >= 1 && _adService.isRewardedAdReady) {
      _adService.showRewardedAd(
        onRewarded: () async {
          final newQuote = _quoteService.getRandomQuote(category: _selectedCategory);
          setState(() {
            _currentQuote = newQuote;
            _quotesViewedToday++;
          });
          
          // Add XP for reading
          _userProgress = await _progressService.addQuoteRead(newQuote.category);
          setState(() {});
          
          // Show interstitial ad occasionally
          if (_quotesViewedToday % 3 == 0 && _adService.isInterstitialAdReady) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _adService.showInterstitialAd();
            });
          }
        },
        onAdClosed: () {
          // Ad wasn't watched completely, don't load new quote
        },
      );
    } else if (_quotesViewedToday == 0) {
      // First quote is free
      final newQuote = _quoteService.getRandomQuote(category: _selectedCategory);
      setState(() {
        _currentQuote = newQuote;
        _quotesViewedToday++;
      });
      
      // Add XP for reading
      _progressService.addQuoteRead(newQuote.category).then((progress) {
        setState(() {
          _userProgress = progress;
        });
      });
    } else if (!_adService.isRewardedAdReady) {
      // Rewarded ad not ready
      _showAdNotReadyDialog();
      // Try to reload the ad
      _adService.loadRewardedAd();
    }
  }

  void _showAdNotReadyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Hold Up',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Loading your motivation fuel. Try again in a moment.\n\nFor now, here\'s a bonus quote without ads.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Give a free quote while ad loads
              setState(() {
                _currentQuote = _quoteService.getRandomQuote();
                _quotesViewedToday++;
              });
            },
            child: const Text('Get Free Quote'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Wait'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'RIPPED FOR REAL',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Progress Header
                  ProgressHeader(progress: _userProgress),
                  // Category Filter
                  CategoryFilter(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                  // Main content with level progress
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Enhanced Level Progress Widget
                            LevelProgressWidget(
                              level: _userProgress.level,
                              currentXP: _userProgress.currentLevelXP,
                              maxXP: 100,
                              levelTitle: _getLevelTitle(_userProgress.level),
                            ),
                            const SizedBox(height: 20),
                            // Quote Card
                            _currentQuote != null
                                ? QuoteCard(
                                    quote: _currentQuote!,
                                    onFavoriteToggle: () async {
                                      setState(() {
                                        _quoteService.toggleFavorite(_currentQuote!);
                                      });
                                      // Add XP for saving
                                      _userProgress = await _progressService.addQuoteSaved();
                                      setState(() {});
                                    },
                                    isFavorite: _quoteService.isFavorite(_currentQuote!.id),
                                  )
                                : const Text(
                                    'Loading your daily motivation...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _loadNextQuote,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text(
                        _quotesViewedToday == 0 ? 'GET TODAY\'S QUOTE' : 'NEXT QUOTE',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
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
  
  String _getLevelTitle(int level) {
    if (level >= 30) return 'Legend';
    if (level >= 20) return 'Champion';
    if (level >= 10) return 'Warrior';
    return 'Rookie';
  }
}