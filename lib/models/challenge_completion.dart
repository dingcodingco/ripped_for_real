class ChallengeCompletion {
  final DateTime completedDate;
  final String challengeType;
  final String responseText;
  final String? imagePath;
  final DateTime timestamp;
  final int quoteId;

  ChallengeCompletion({
    required this.completedDate,
    required this.challengeType,
    required this.responseText,
    this.imagePath,
    required this.timestamp,
    required this.quoteId,
  });

  Map<String, dynamic> toJson() {
    return {
      'completedDate': completedDate.toIso8601String(),
      'challengeType': challengeType,
      'responseText': responseText,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'quoteId': quoteId,
    };
  }

  factory ChallengeCompletion.fromJson(Map<String, dynamic> json) {
    return ChallengeCompletion(
      completedDate: DateTime.parse(json['completedDate']),
      challengeType: json['challengeType'],
      responseText: json['responseText'],
      imagePath: json['imagePath'],
      timestamp: DateTime.parse(json['timestamp']),
      quoteId: json['quoteId'] ?? 0,
    );
  }

  // Create a unique key for this completion (quote-based)
  String get key => '${completedDate.year}-${completedDate.month.toString().padLeft(2, '0')}-${completedDate.day.toString().padLeft(2, '0')}-quote-$quoteId';
}