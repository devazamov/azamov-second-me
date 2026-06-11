/// ═══════════════════════════════════════════════════════════════
/// Progress & Achievement Models - AZAMOV Second Me
/// Track user progress, achievements, and analytics
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

/// ═══════════════════════════════════════════════════════════════
/// Achievement Model
/// ═══════════════════════════════════════════════════════════════

enum AchievementRarity { common, rare, epic, legendary }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementRarity rarity;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int requiredValue;
  final String requirementType; // streak, xp, missions, chats, level

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.rarity,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.requiredValue,
    required this.requirementType,
  });

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Achievement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '🏅',
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == data['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate(),
      requiredValue: data['requiredValue'] ?? 0,
      requirementType: data['requirementType'] ?? 'xp',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'rarity': rarity.name,
      'isUnlocked': isUnlocked,
      'unlockedAt':
          unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'requiredValue': requiredValue,
      'requirementType': requirementType,
    };
  }
}

/// ═══════════════════════════════════════════════════════════════
/// Daily Progress Model
/// ═══════════════════════════════════════════════════════════════

class DailyProgress {
  final String id;
  final String userId;
  final DateTime date;
  final int xpEarned;
  final int missionsCompleted;
  final int chatsHad;
  final int wordsLearned;
  final int minutesActive;

  const DailyProgress({
    required this.id,
    required this.userId,
    required this.date,
    this.xpEarned = 0,
    this.missionsCompleted = 0,
    this.chatsHad = 0,
    this.wordsLearned = 0,
    this.minutesActive = 0,
  });

  factory DailyProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DailyProgress(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      xpEarned: data['xpEarned'] ?? 0,
      missionsCompleted: data['missionsCompleted'] ?? 0,
      chatsHad: data['chatsHad'] ?? 0,
      wordsLearned: data['wordsLearned'] ?? 0,
      minutesActive: data['minutesActive'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'xpEarned': xpEarned,
      'missionsCompleted': missionsCompleted,
      'chatsHad': chatsHad,
      'wordsLearned': wordsLearned,
      'minutesActive': minutesActive,
    };
  }
}

/// ═══════════════════════════════════════════════════════════════
/// Weekly Stats Summary
/// ═══════════════════════════════════════════════════════════════

class WeeklyStats {
  final List<DailyProgress> dailyProgress;
  final int totalXp;
  final int totalMissions;
  final int totalChats;
  final int activeDays;

  const WeeklyStats({
    required this.dailyProgress,
    required this.totalXp,
    required this.totalMissions,
    required this.totalChats,
    required this.activeDays,
  });

  factory WeeklyStats.fromProgressList(List<DailyProgress> progress) {
    return WeeklyStats(
      dailyProgress: progress,
      totalXp: progress.fold(0, (sum, p) => sum + p.xpEarned),
      totalMissions:
          progress.fold(0, (sum, p) => sum + p.missionsCompleted),
      totalChats: progress.fold(0, (sum, p) => sum + p.chatsHad),
      activeDays: progress.where((p) => p.xpEarned > 0).length,
    );
  }

  /// Average XP per day
  double get averageXp => totalXp / 7.0;
}
