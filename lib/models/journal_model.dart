/// ═══════════════════════════════════════════════════════════════
/// Journal Model - AZAMOV Second Me
/// Daily reflections and notes
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum JournalMood { amazing, good, neutral, bad, terrible }

class JournalEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String content;
  final JournalMood mood;
  final List<String> tags;
  final List<String> gratitudes; // Things user is grateful for
  final String? todayWin; // One win for today
  final String? tomorrowGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.date,
    this.content = '',
    this.mood = JournalMood.neutral,
    this.tags = const [],
    this.gratitudes = const [],
    this.todayWin,
    this.tomorrowGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  String get moodEmoji {
    switch (mood) {
      case JournalMood.amazing:
        return '😄';
      case JournalMood.good:
        return '🙂';
      case JournalMood.neutral:
        return '😐';
      case JournalMood.bad:
        return '😞';
      case JournalMood.terrible:
        return '😢';
    }
  }

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return JournalEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      content: data['content'] ?? '',
      mood: JournalMood.values.firstWhere(
        (e) => e.name == data['mood'],
        orElse: () => JournalMood.neutral,
      ),
      tags: List<String>.from(data['tags'] ?? []),
      gratitudes: List<String>.from(data['gratitudes'] ?? []),
      todayWin: data['todayWin'],
      tomorrowGoal: data['tomorrowGoal'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'content': content,
      'mood': mood.name,
      'tags': tags,
      'gratitudes': gratitudes,
      'todayWin': todayWin,
      'tomorrowGoal': tomorrowGoal,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  JournalEntry copyWith({
    String? content,
    JournalMood? mood,
    List<String>? tags,
    List<String>? gratitudes,
    String? todayWin,
    String? tomorrowGoal,
  }) {
    return JournalEntry(
      id: id,
      userId: userId,
      date: date,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      gratitudes: gratitudes ?? this.gratitudes,
      todayWin: todayWin ?? this.todayWin,
      tomorrowGoal: tomorrowGoal ?? this.tomorrowGoal,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
