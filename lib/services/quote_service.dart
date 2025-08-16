import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/quote.dart';

class QuoteService {
  static final QuoteService _instance = QuoteService._internal();
  factory QuoteService() => _instance;
  QuoteService._internal();

  List<Quote> _allQuotes = [];
  final _random = Random();

  Future<void> loadQuotes() async {
    if (_allQuotes.isNotEmpty) return;
    
    final String jsonString = await rootBundle.loadString('assets/quotes.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> quotesJson = jsonData['quotes'];
    
    _allQuotes = quotesJson.map((json) => Quote.fromJson(json)).toList();
  }

  List<Quote> getAllQuotes() {
    return _allQuotes;
  }

  Quote getRandomQuote({String? category}) {
    if (_allQuotes.isEmpty) {
      return Quote(
        id: 0,
        text: "Stay hard. Load failed but you're still here.",
        category: "mindset",
      );
    }
    
    // Filter by category if specified
    if (category != null) {
      final filteredQuotes = _allQuotes.where((q) => q.category == category).toList();
      if (filteredQuotes.isNotEmpty) {
        return filteredQuotes[_random.nextInt(filteredQuotes.length)];
      }
    }
    
    return _allQuotes[_random.nextInt(_allQuotes.length)];
  }

  Quote? getDailyQuote() {
    final box = Hive.box('daily_quote');
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = box.get('last_date');
    
    if (lastDate != today || !box.containsKey('quote_id')) {
      final quote = getRandomQuote();
      box.put('last_date', today);
      box.put('quote_id', quote.id);
      return quote;
    }
    
    final quoteId = box.get('quote_id');
    return _allQuotes.firstWhere(
      (q) => q.id == quoteId,
      orElse: () => getRandomQuote(),
    );
  }

  List<Quote> getFavoriteQuotes() {
    final box = Hive.box('favorites');
    final favoriteIds = box.get('quotes', defaultValue: <int>[]) as List;
    
    return favoriteIds
        .map((id) => _allQuotes.firstWhere(
              (q) => q.id == id,
              orElse: () => Quote(id: 0, text: '', category: ''),
            ))
        .where((q) => q.text.isNotEmpty)
        .toList()
        .reversed
        .toList();
  }

  bool isFavorite(int quoteId) {
    final box = Hive.box('favorites');
    final favoriteIds = box.get('quotes', defaultValue: <int>[]) as List;
    return favoriteIds.contains(quoteId);
  }

  void toggleFavorite(Quote quote) {
    final box = Hive.box('favorites');
    final favoriteIds = box.get('quotes', defaultValue: <int>[]) as List;
    final mutableList = List<int>.from(favoriteIds);
    
    if (mutableList.contains(quote.id)) {
      mutableList.remove(quote.id);
    } else {
      mutableList.add(quote.id);
    }
    
    box.put('quotes', mutableList);
  }
}