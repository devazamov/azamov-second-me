/// ═══════════════════════════════════════════════════════════════
/// User Model - AZAMOV Second Me
/// Stores user profile, goals, and preferences
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final int age;
  final String gender;
  final List<String> goals;
  final List<String> dreams;
  final List<String> interests;
  final String preferredLanguage;
  final bool isPremium;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int dailyChatsUsed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveDate;
  final bool onboardingCompleted;
  final bool notificationsEnabled;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.age,
    required this.gender,
    this.goals = const [],
    this.dreams = const [],
    this.interests = const [],
    this.preferredLanguage = 'uz',
    this.isPremium = false,
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.dailyChatsUsed = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveDate,
    this.onboardingCompleted = false,
    this.notificationsEnabled = true,
  });

  /// Maximum daily AI chats for free users
  static const int maxFreeDailyChats = 5;

  /// XP required per level
  static int xpForLevel(int level) => level * 100;

  /// Whether user can start a new AI chat
  bool get canStartChat => isPremium || dailyChatsUsed < maxFreeDailyChats;

  /// Progress to next level (0.0 to 1.0)
  double get levelProgress {
    final currentLevelXp = xp - (level > 1 ? _totalXpForLevel(level - 1) : 0);
    final requiredXp = xpForLevel(level);
    return (currentLevelXp / requiredXp).clamp(0.0, 1.0);
  }

  /// Calculate total XP needed to reach a given level
  static int _totalXpForLevel(int level) {
    int total = 0;
    for (int i = 1; i <= level; i++) {
      total += xpForLevel(i);
    }
    return total;
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      goals: List<String>.from(data['goals'] ?? []),
      dreams: List<String>.from(data['dreams'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      preferredLanguage: data['preferredLanguage'] ?? 'uz',
      isPremium: data['isPremium'] ?? false,
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      dailyChatsUsed: data['dailyChatsUsed'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
      onboardingCompleted: data['onboardingCompleted'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'age': age,
      'gender': gender,
      'goals': goals,
      'dreams': dreams,
      'interests': interests,
      'preferredLanguage': preferredLanguage,
      'isPremium': isPremium,
      'xp': xp,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'dailyChatsUsed': dailyChatsUsed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActiveDate':
          lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      'onboardingCompleted': onboardingCompleted,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  /// Create a copy with modifications
  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    int? age,
    String? gender,
    List<String>? goals,
    List<String>? dreams,
    List<String>? interests,
    String? preferredLanguage,
    bool? isPremium,
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    int? dailyChatsUsed,
    DateTime? lastActiveDate,
    bool? onboardingCompleted,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goals: goals ?? this.goals,
      dreams: dreams ?? this.dreams,
      interests: interests ?? this.interests,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isPremium: isPremium ?? this.isPremium,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      dailyChatsUsed: dailyChatsUsed ?? this.dailyChatsUsed,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
