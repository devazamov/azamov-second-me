/// ═══════════════════════════════════════════════════════════════
/// Mission Model - AZAMOV Second Me
/// Represents daily personalized missions for self-improvement
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum MissionCategory { learning, reading, health, creative, social, productivity }
enum MissionDifficulty { easy, medium, hard }

class Mission {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final MissionCategory category;
  final MissionDifficulty difficulty;
  final int xpReward;
  final Duration estimatedTime;
  final bool isPremium;
  final DateTime createdAt;
  final bool isActive;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    required this.estimatedTime,
    this.isPremium = false,
    required this.createdAt,
    this.isActive = true,
  });

  /// XP multiplier based on difficulty
  double get difficultyMultiplier {
    switch (difficulty) {
      case MissionDifficulty.easy:
        return 1.0;
      case MissionDifficulty.medium:
        return 1.5;
      case MissionDifficulty.hard:
        return 2.0;
    }
  }

  /// Calculate total XP with difficulty bonus
  int get totalXp => (xpReward * difficultyMultiplier).round();

  /// Display time estimate
  String get timeEstimate {
    if (estimatedTime.inHours >= 1) {
      return '${estimatedTime.inHours}h';
    }
    return '${estimatedTime.inMinutes}min';
  }

  factory Mission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Mission(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '🎯',
      category: MissionCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => MissionCategory.learning,
      ),
      difficulty: MissionDifficulty.values.firstWhere(
        (e) => e.name == data['difficulty'],
        orElse: () => MissionDifficulty.medium,
      ),
      xpReward: data['xpReward'] ?? 10,
      estimatedTime: Duration(minutes: data['estimatedMinutes'] ?? 30),
      isPremium: data['isPremium'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'category': category.name,
      'difficulty': difficulty.name,
      'xpReward': xpReward,
      'estimatedMinutes': estimatedTime.inMinutes,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}

/// ═══════════════════════════════════════════════════════════════
/// Completed Mission Model
/// ═══════════════════════════════════════════════════════════════

class CompletedMission {
  final String id;
  final String userId;
  final String missionId;
  final String missionTitle;
  final String missionEmoji;
  final int xpEarned;
  final DateTime completedAt;

  const CompletedMission({
    required this.id,
    required this.userId,
    required this.missionId,
    required this.missionTitle,
    required this.missionEmoji,
    required this.xpEarned,
    required this.completedAt,
  });

  factory CompletedMission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CompletedMission(
      id: doc.id,
      userId: data['userId'] ?? '',
      missionId: data['missionId'] ?? '',
      missionTitle: data['missionTitle'] ?? '',
      missionEmoji: data['missionEmoji'] ?? '🎯',
      xpEarned: data['xpEarned'] ?? 0,
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'missionId': missionId,
      'missionTitle': missionTitle,
      'missionEmoji': missionEmoji,
      'xpEarned': xpEarned,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}
