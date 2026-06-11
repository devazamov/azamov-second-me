/// ═══════════════════════════════════════════════════════════════
/// Challenge Model - AZAMOV Second Me
/// Weekly and monthly challenges with XP rewards
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum ChallengeCategory { fitness, learning, mindfulness, productivity, creative, social, custom }
enum ChallengeDifficulty { beginner, intermediate, advanced }
enum ChallengePeriod { weekly, monthly }
enum ChallengeStatus { active, completed, expired, failed }

class Challenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final ChallengeCategory category;
  final ChallengeDifficulty difficulty;
  final ChallengePeriod period;
  final int totalDays;
  final int xpReward;
  final int bonusXp; // Bonus XP for completing all days
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> dailyTasks; // Tasks for each day
  final bool isPremium;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.difficulty,
    required this.period,
    required this.totalDays,
    required this.xpReward,
    this.bonusXp = 0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.dailyTasks = const [],
    this.isPremium = false,
  });

  String get difficultyLabel {
    switch (difficulty) {
      case ChallengeDifficulty.beginner:
        return 'Boshlang\'ich';
      case ChallengeDifficulty.intermediate:
        return 'O\'rta';
      case ChallengeDifficulty.advanced:
        return 'Murakkab';
    }
  }

  String get periodLabel {
    switch (period) {
      case ChallengePeriod.weekly:
        return 'Haftalik';
      case ChallengePeriod.monthly:
        return 'Oylik';
    }
  }

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Challenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '🏆',
      category: ChallengeCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => ChallengeCategory.custom,
      ),
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.name == data['difficulty'],
        orElse: () => ChallengeDifficulty.beginner,
      ),
      period: ChallengePeriod.values.firstWhere(
        (e) => e.name == data['period'],
        orElse: () => ChallengePeriod.weekly,
      ),
      totalDays: data['totalDays'] ?? 7,
      xpReward: data['xpReward'] ?? 50,
      bonusXp: data['bonusXp'] ?? 0,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      dailyTasks: List<String>.from(data['dailyTasks'] ?? []),
      isPremium: data['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'category': category.name,
      'difficulty': difficulty.name,
      'period': period.name,
      'totalDays': totalDays,
      'xpReward': xpReward,
      'bonusXp': bonusXp,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'dailyTasks': dailyTasks,
      'isPremium': isPremium,
    };
  }
}

/// ═══════════════════════════════════════════════════════════════
/// User's Challenge Progress
/// ═══════════════════════════════════════════════════════════════

class UserChallenge {
  final String id;
  final String userId;
  final String challengeId;
  final String challengeTitle;
  final String challengeEmoji;
  final ChallengePeriod period;
  final int totalDays;
  final int xpReward;
  final int bonusXp;
  final ChallengeStatus status;
  final DateTime joinedAt;
  final DateTime? completedAt;
  final List<int> completedDays; // Day indices (1-based)
  final int currentDay;

  const UserChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.challengeTitle,
    required this.challengeEmoji,
    required this.period,
    required this.totalDays,
    this.xpReward = 0,
    this.bonusXp = 0,
    this.status = ChallengeStatus.active,
    required this.joinedAt,
    this.completedAt,
    this.completedDays = const [],
    this.currentDay = 1,
  });

  double get progress => totalDays > 0 ? completedDays.length / totalDays : 0.0;
  bool get isCompleted => status == ChallengeStatus.completed;

  factory UserChallenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserChallenge(
      id: doc.id,
      userId: data['userId'] ?? '',
      challengeId: data['challengeId'] ?? '',
      challengeTitle: data['challengeTitle'] ?? '',
      challengeEmoji: data['challengeEmoji'] ?? '🏆',
      period: ChallengePeriod.values.firstWhere(
        (e) => e.name == data['period'],
        orElse: () => ChallengePeriod.weekly,
      ),
      totalDays: data['totalDays'] ?? 7,
      xpReward: data['xpReward'] ?? 0,
      bonusXp: data['bonusXp'] ?? 0,
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ChallengeStatus.active,
      ),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      completedDays: List<int>.from(data['completedDays'] ?? []),
      currentDay: data['currentDay'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'challengeTitle': challengeTitle,
      'challengeEmoji': challengeEmoji,
      'period': period.name,
      'totalDays': totalDays,
      'xpReward': xpReward,
      'bonusXp': bonusXp,
      'status': status.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'completedDays': completedDays,
      'currentDay': currentDay,
    };
  }

  UserChallenge copyWith({
    ChallengeStatus? status,
    DateTime? completedAt,
    List<int>? completedDays,
    int? currentDay,
  }) {
    return UserChallenge(
      id: id,
      userId: userId,
      challengeId: challengeId,
      challengeTitle: challengeTitle,
      challengeEmoji: challengeEmoji,
      period: period,
      totalDays: totalDays,
      xpReward: xpReward,
      bonusXp: bonusXp,
      status: status ?? this.status,
      joinedAt: joinedAt,
      completedAt: completedAt ?? this.completedAt,
      completedDays: completedDays ?? this.completedDays,
      currentDay: currentDay ?? this.currentDay,
    );
  }
}
