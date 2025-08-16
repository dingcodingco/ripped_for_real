import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/quote.dart';
import '../models/challenge_completion.dart';
import '../services/quote_service.dart';
import '../services/challenge_service.dart';

class SavedQuotesScreenV2 extends StatefulWidget {
  const SavedQuotesScreenV2({super.key});

  @override
  State<SavedQuotesScreenV2> createState() => _SavedQuotesScreenV2State();
}

class _SavedQuotesScreenV2State extends State<SavedQuotesScreenV2>
    with SingleTickerProviderStateMixin {
  final QuoteService _quoteService = QuoteService();
  final ChallengeService _challengeService = ChallengeService();
  final ScreenshotController _screenshotController = ScreenshotController();
  
  late TabController _tabController;
  List<Quote> _favoriteQuotes = [];
  List<ChallengeCompletion> _completedChallenges = [];
  Map<String, Quote> _quotesByDate = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    // Load favorite quotes
    setState(() {
      _favoriteQuotes = _quoteService.getFavoriteQuotes();
    });
    
    // Load completed challenges
    _loadCompletedChallenges();
  }
  
  void _loadCompletedChallenges() {
    final completions = _challengeService.getAllCompletions();
    final quotes = _quoteService.getAllQuotes();
    
    // Create a map of quotes by date for easy lookup
    _quotesByDate.clear();
    for (final completion in completions) {
      // Find the quote for this date based on the quote service logic
      final dateKey = '${completion.completedDate.year}-${completion.completedDate.month}-${completion.completedDate.day}';
      final quoteIndex = completion.completedDate.day % quotes.length;
      _quotesByDate[dateKey] = quotes[quoteIndex];
    }
    
    setState(() {
      _completedChallenges = completions;
    });
  }

  Future<void> _shareQuote(Quote quote, {ChallengeCompletion? completion}) async {
    try {
      final image = await _screenshotController.captureFromWidget(
        _buildShareCard(quote, completion: completion),
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/quote_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: completion != null 
            ? 'Completed my daily challenge! 💪 #RippedForReal' 
            : 'Stay hard! 💪 #RippedForReal',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share')),
        );
      }
    }
  }

  Widget _buildShareCard(Quote quote, {ChallengeCompletion? completion}) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'RIPPED FOR REAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '"${quote.text}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (completion != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MY CHALLENGE RESPONSE:',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    completion.responseText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              quote.category.toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'MY COLLECTION',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              text: 'FAVORITES',
              icon: Icon(Icons.favorite, size: 20),
            ),
            Tab(
              text: 'CHALLENGES',
              icon: Icon(Icons.flag, size: 20),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Favorites Tab
          _buildFavoritesTab(),
          // Challenges Tab
          _buildChallengesTab(),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_favoriteQuotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart to save quotes',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteQuotes.length,
      itemBuilder: (context, index) {
        final quote = _favoriteQuotes[index];
        return _buildQuoteCard(quote, isFavorite: true);
      },
    );
  }

  Widget _buildChallengesTab() {
    if (_completedChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              'No completed challenges yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete daily challenges to see them here',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedChallenges.length,
      itemBuilder: (context, index) {
        final completion = _completedChallenges[index];
        final dateKey = '${completion.completedDate.year}-${completion.completedDate.month}-${completion.completedDate.day}';
        final quote = _quotesByDate[dateKey];
        
        if (quote == null) return const SizedBox();
        
        return _buildChallengeCard(quote, completion);
      },
    );
  }

  Widget _buildQuoteCard(Quote quote, {required bool isFavorite}) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${quote.text}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quote.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _shareQuote(quote),
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white54,
                      ),
                    ),
                    if (isFavorite)
                      IconButton(
                        onPressed: () {
                          _quoteService.toggleFavorite(quote);
                          _loadData();
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Quote quote, ChallengeCompletion completion) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(completion.completedDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quote
            Text(
              '"${quote.text}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Challenge response
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getChallengeTitle(completion.challengeType),
                    style: TextStyle(
                      color: Colors.green[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completion.responseText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quote.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _shareQuote(quote, completion: completion),
                  icon: const Icon(
                    Icons.share,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getChallengeTitle(String type) {
    switch (type) {
      case 'mindset':
        return '🧠 GRATITUDE LIST';
      case 'money':
        return '💰 MONEY SAVED';
      case 'strength':
        return '💪 WORKOUT COMPLETED';
      case 'discipline':
        return '⏰ WAKE UP TIME';
      case 'success':
        return '📈 TASK COMPLETED';
      default:
        return '✅ CHALLENGE RESPONSE';
    }
  }
}