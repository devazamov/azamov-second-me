/// ═══════════════════════════════════════════════════════════════
/// Habit Model - AZAMOV Second Me
/// Track daily recurring habits with streaks
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum HabitFrequency { daily, weekly, weekday, weekend }
enum HabitCategory { health, learning, productivity, mindfulness, social, creative }

class Habit {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String emoji;
  final HabitCategory category;
  final HabitFrequency frequency;
  final int targetCount; // e.g., 3 times per day/week
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final List<String> reminderTimes; // HH:mm format

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.emoji,
    required this.category,
    this.frequency = HabitFrequency.daily,
    this.targetCount = 1,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    this.reminderTimes = const [],
  });

  factory Habit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Habit(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '✅',
      category: HabitCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => HabitCategory.productivity,
      ),
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.name == data['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      targetCount: data['targetCount'] ?? 1,
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reminderTimes: List<String>.from(data['reminderTimes'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'emoji': emoji,
      'category': category.name,
      'frequency': frequency.name,
      'targetCount': targetCount,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'reminderTimes': reminderTimes,
    };
  }

  Habit copyWith({
    String? title,
    String? description,
    String? emoji,
    HabitCategory? category,
    HabitFrequency? frequency,
    int? targetCount,
    int? sortOrder,
    bool? isActive,
    List<String>? reminderTimes,
  }) {
    return Habit(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetCount: targetCount ?? this.targetCount,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      reminderTimes: reminderTimes ?? this.reminderTimes,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// Habit Log - Daily check-in record
/// ═══════════════════════════════════════════════════════════════

class HabitLog {
  final String id;
  final String userId;
  final String habitId;
  final DateTime date;
  final int count;
  final String? note;

  const HabitLog({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.date,
    this.count = 1,
    this.note,
  });

  bool get isCompleted => count > 0;

  factory HabitLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HabitLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      habitId: data['habitId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      count: data['count'] ?? 1,
      note: data['note'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'habitId': habitId,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'count': count,
      'note': note,
    };
  }
}
