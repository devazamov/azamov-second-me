/// ═══════════════════════════════════════════════════════════════
/// Firestore Service - AZAMOV Academy
/// All Firestore database operations
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/mission_model.dart';
import '../models/progress_model.dart';
import '../models/subscription_model.dart';
import '../models/habit_model.dart';
import '../models/journal_model.dart';
import '../models/mood_model.dart';
import '../models/challenge_model.dart';
import '../models/focus_model.dart';
import '../models/bookmark_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Public access to database for custom queries
  FirebaseFirestore get db => _db;

  // ─── Collection References ───
  CollectionReference get _usersRef => _db.collection('users');
  CollectionReference get _chatHistoryRef => _db.collection('chat_history');
  CollectionReference get _missionsRef => _db.collection('missions');
  CollectionReference get _completedMissionsRef => _db.collection('completed_missions');
  CollectionReference get _progressRef => _db.collection('progress');
  CollectionReference get _achievementsRef => _db.collection('achievements');
  CollectionReference get _subscriptionsRef => _db.collection('subscriptions');
  CollectionReference get _habitsRef => _db.collection('habits');
  CollectionReference get _habitLogsRef => _db.collection('habit_logs');
  CollectionReference get _journalRef => _db.collection('journal');
  CollectionReference get _moodRef => _db.collection('moods');
  CollectionReference get _challengesRef => _db.collection('challenges');
  CollectionReference get _userChallengesRef => _db.collection('user_challenges');
  CollectionReference get _focusSessionsRef => _db.collection('focus_sessions');

  // ═══════════════════════════════════════════════════════════════
  // USER OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<UserModel?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> userStream(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) {
    return _usersRef.doc(userId).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateOnboarding(String userId, {
    required String name, required int age, required String gender,
    required List<String> goals, required List<String> dreams, required List<String> interests,
  }) {
    return _usersRef.doc(userId).update({
      'name': name, 'age': age, 'gender': gender,
      'goals': goals, 'dreams': dreams, 'interests': interests,
      'onboardingCompleted': true, 'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addXp(String userId, int xp) async {
    final user = await getUser(userId);
    if (user == null) return;
    final newTotalXp = user.xp + xp;
    var newLevel = user.level;
    while (newTotalXp >= UserModel.xpForLevel(newLevel)) newLevel++;
    await _usersRef.doc(userId).update({
      'xp': newTotalXp, 'level': newLevel, 'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resetDailyChats(String userId) {
    return _usersRef.doc(userId).update({'dailyChatsUsed': 0, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> incrementDailyChats(String userId) {
    return _usersRef.doc(userId).update({
      'dailyChatsUsed': FieldValue.increment(1), 'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStreak(String userId, int newStreak) async {
    final user = await getUser(userId);
    if (user == null) return;
    final longestStreak = newStreak > user.longestStreak ? newStreak : user.longestStreak;
    await _usersRef.doc(userId).update({
      'currentStreak': newStreak, 'longestStreak': longestStreak,
      'lastActiveDate': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // CHAT OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<String> createChatSession(String userId) async {
    final doc = await _chatHistoryRef.add({
      'userId': userId, 'title': 'New Chat',
      'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
      'messageCount': 0, 'isActive': true,
    });
    return doc.id;
  }

  Future<void> sendMessage(ChatMessage message) async {
    await _chatHistoryRef.doc(message.chatId).collection('messages').doc(message.id).set(message.toFirestore());
    await _chatHistoryRef.doc(message.chatId).update({
      'messageCount': FieldValue.increment(1), 'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _chatHistoryRef.doc(chatId).collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  Stream<List<ChatSession>> getUserChatSessions(String userId) {
    return _chatHistoryRef.where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true).limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatSession.fromFirestore(doc)).toList());
  }

  Future<List<ChatMessage>> getRecentMessages(String chatId, {int limit = 20}) async {
    final snapshot = await _chatHistoryRef.doc(chatId).collection('messages')
        .orderBy('timestamp', descending: true).limit(limit).get();
    return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList().reversed.toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // MISSION OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<List<Mission>> getActiveMissions() async {
    final snapshot = await _missionsRef.where('isActive', isEqualTo: true).get();
    return snapshot.docs.map((doc) => Mission.fromFirestore(doc)).toList();
  }

  Stream<List<Mission>> getDailyMissions(bool isPremium) {
    return _missionsRef.where('isActive', isEqualTo: true).where('isPremium', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Mission.fromFirestore(doc)).toList());
  }

  Future<void> completeMission(CompletedMission completed) async {
    await _completedMissionsRef.doc(completed.id).set(completed.toFirestore());
  }

  Future<List<CompletedMission>> getTodayCompletedMissions(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final snapshot = await _completedMissionsRef
        .where('userId', isEqualTo: userId)
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();
    return snapshot.docs.map((doc) => CompletedMission.fromFirestore(doc)).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // PROGRESS OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<void> updateDailyProgress(String userId, {int xpEarned = 0, int missionsCompleted = 0, int chatsHad = 0}) async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final docId = '${userId}_$dateStr';
    final doc = await _progressRef.doc(docId).get();
    if (doc.exists) {
      await _progressRef.doc(docId).update({
        'xpEarned': FieldValue.increment(xpEarned),
        'missionsCompleted': FieldValue.increment(missionsCompleted),
        'chatsHad': FieldValue.increment(chatsHad),
      });
    } else {
      await _progressRef.doc(docId).set({
        'userId': userId, 'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
        'xpEarned': xpEarned, 'missionsCompleted': missionsCompleted, 'chatsHad': chatsHad,
        'wordsLearned': 0, 'minutesActive': 0,
      });
    }
  }

  Future<List<DailyProgress>> getWeeklyProgress(String userId) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final snapshot = await _progressRef.where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .orderBy('date', descending: false).get();
    return snapshot.docs.map((doc) => DailyProgress.fromFirestore(doc)).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // ACHIEVEMENT OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Stream<List<Achievement>> getUserAchievements(String userId) {
    return _achievementsRef.where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Achievement.fromFirestore(doc)).toList());
  }

  Future<void> unlockAchievement(Achievement achievement) async {
    await _achievementsRef.doc(achievement.id).set(achievement.toFirestore());
  }

  // ═══════════════════════════════════════════════════════════════
  // SUBSCRIPTION OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<bool> isPremiumUser(String userId) async {
    final snapshot = await _subscriptionsRef.where('userId', isEqualTo: userId).where('status', isEqualTo: 'active').limit(1).get();
    if (snapshot.docs.isEmpty) return false;
    return Subscription.fromFirestore(snapshot.docs.first).isActive;
  }

  // ═══════════════════════════════════════════════════════════════
  // HABIT OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Stream<List<Habit>> getUserHabits(String userId) {
    return _habitsRef.where('userId', isEqualTo: userId).where('isActive', isEqualTo: true).orderBy('sortOrder')
        .snapshots().map((snap) => snap.docs.map((d) => Habit.fromFirestore(d)).toList());
  }

  Future<String> createHabit(Habit habit) async {
    final doc = await _habitsRef.add(habit.toFirestore());
    return doc.id;
  }

  Future<void> updateHabit(String habitId, Map<String, dynamic> data) async {
    await _habitsRef.doc(habitId).update(data);
  }

  Future<void> deactivateHabit(String habitId) async {
    await _habitsRef.doc(habitId).update({'isActive': false});
  }

  Future<void> logHabitCompletion(HabitLog log) async {
    await _habitLogsRef.doc(log.id).set(log.toFirestore());
  }

  Future<List<HabitLog>> getTodayHabitLogs(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final snapshot = await _habitLogsRef.where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay)).get();
    return snapshot.docs.map((doc) => HabitLog.fromFirestore(doc)).toList();
  }

  Future<List<HabitLog>> getWeeklyHabitLogs(String userId, String habitId) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final snapshot = await _habitLogsRef.where('userId', isEqualTo: userId).where('habitId', isEqualTo: habitId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo)).orderBy('date', descending: false).get();
    return snapshot.docs.map((doc) => HabitLog.fromFirestore(doc)).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // JOURNAL OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Stream<List<JournalEntry>> getUserJournal(String userId) {
    return _journalRef.where('userId', isEqualTo: userId).orderBy('date', descending: true)
        .snapshots().map((snap) => snap.docs.map((d) => JournalEntry.fromFirestore(d)).toList());
  }

  Future<JournalEntry?> getTodayJournal(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final snapshot = await _journalRef.where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay)).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return JournalEntry.fromFirestore(snapshot.docs.first);
  }

  Future<void> saveJournalEntry(JournalEntry entry) async {
    await _journalRef.doc(entry.id).set(entry.toFirestore());
  }

  // ═══════════════════════════════════════════════════════════════
  // MOOD OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<void> logMood(MoodEntry entry) async {
    await _moodRef.doc(entry.id).set(entry.toFirestore());
  }

  Future<MoodEntry?> getTodayMood(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final snapshot = await _moodRef.where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay)).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return MoodEntry.fromFirestore(snapshot.docs.first);
  }

  Future<List<MoodEntry>> getMoodHistory(String userId) async {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _moodRef.where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monthAgo))
        .orderBy('date', descending: false).get();
    return snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // CHALLENGE OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Stream<List<Challenge>> getActiveChallenges() {
    final now = Timestamp.now();
    return _challengesRef.where('isActive', isEqualTo: true).where('endDate', isGreaterThanOrEqualTo: now)
        .snapshots().map((snap) => snap.docs.map((d) => Challenge.fromFirestore(d)).toList());
  }

  Stream<List<UserChallenge>> getUserChallenges(String userId) {
    return _userChallengesRef.where('userId', isEqualTo: userId).orderBy('joinedAt', descending: true)
        .snapshots().map((snap) => snap.docs.map((d) => UserChallenge.fromFirestore(d)).toList());
  }

  Future<void> joinChallenge(UserChallenge userChallenge) async {
    await _userChallengesRef.doc(userChallenge.id).set(userChallenge.toFirestore());
  }

  Future<void> completeChallengeDay(String userChallengeId, int dayIndex) async {
    final doc = await _userChallengesRef.doc(userChallengeId).get();
    if (!doc.exists) return;
    final uc = UserChallenge.fromFirestore(doc);
    final updatedCompletedDays = [...uc.completedDays, dayIndex];
    final isFullyComplete = updatedCompletedDays.length >= uc.totalDays;
    await _userChallengesRef.doc(userChallengeId).update({
      'completedDays': updatedCompletedDays, 'currentDay': dayIndex + 1,
      if (isFullyComplete) 'status': 'completed',
      if (isFullyComplete) 'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // FOCUS SESSION OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<void> saveFocusSession(FocusSession session) async {
    await _focusSessionsRef.doc(session.id).set(session.toFirestore());
  }

  Future<List<FocusSession>> getTodayFocusSessions(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final snapshot = await _focusSessionsRef.where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('startTime', descending: false).get();
    return snapshot.docs.map((doc) => FocusSession.fromFirestore(doc)).toList();
  }

  Future<List<FocusSession>> getWeeklyFocusSessions(String userId) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final snapshot = await _focusSessionsRef.where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .where('status', isEqualTo: 'completed').orderBy('startTime', descending: false).get();
    return snapshot.docs.map((doc) => FocusSession.fromFirestore(doc)).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // BOOKMARK OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  Future<void> saveBookmark(Bookmark bookmark) async {
    await _db.collection('bookmarks').doc(bookmark.id).set(bookmark.toFirestore());
  }

  Stream<List<Bookmark>> getBookmarks(String userId) {
    return _db.collection('bookmarks').where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots().map((snap) => snap.docs.map((doc) => Bookmark.fromFirestore(doc)).toList());
  }

  Future<void> deleteBookmark(String id) async {
    await _db.collection('bookmarks').doc(id).delete();
  }
}
