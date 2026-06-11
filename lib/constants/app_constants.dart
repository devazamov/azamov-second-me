/// ═══════════════════════════════════════════════════════════════
/// App Constants - AZAMOV Second Me
/// Centralized constants for the application
/// ═══════════════════════════════════════════════════════════════

class AppConstants {
  AppConstants._();

  // ─── App Info ───
  static const String appName = 'AZAMOV Second Me';
  static const String appSlogan = 'Kelajakdagi o\'zing bilan bugun gaplash.';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'uz.azamov.azamovSecondMe';

  // ─── Supported Languages ───
  static const Map<String, String> supportedLanguages = {
    'uz': 'O\'zbek',
    'en': 'English',
    'ru': 'Русский',
    'tr': 'Türkçe',
    'de': 'Deutsch',
  };

  // ─── Firestore Collection Names ───
  static const String usersCollection = 'users';
  static const String chatHistoryCollection = 'chat_history';
  static const String missionsCollection = 'missions';
  static const String completedMissionsCollection = 'completed_missions';
  static const String progressCollection = 'progress';
  static const String achievementsCollection = 'achievements';
  static const String notificationsCollection = 'notifications';
  static const String subscriptionsCollection = 'subscriptions';

  // ─── AI Configuration ───
  static const String openAiModel = 'gpt-4o';
  static const String openAiMiniModel = 'gpt-4o-mini';
  static const int maxChatHistoryMessages = 20;
  static const int maxTokens = 1024;
  static const double temperature = 0.7;

  // ─── Premium Configuration ───
  static const int freeDailyChats = 5;
  static const double monthlyPriceUZS = 49000;
  static const String premiumPlanId = 'premium_monthly_uzs';

  // ─── Level System ───
  static const int baseXpPerLevel = 100;

  // ─── Streak Configuration ───
  static const int streakResetHours = 26;

  // ─── Animation Durations ───
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // ─── Achievement Requirements ───
  static const Map<String, Map<String, dynamic>> defaultAchievements = {
    'first_chat': {
      'title': 'Birinchi suhbat',
      'description': 'Kelajagingiz bilan birinchi suhbatni boshlang',
      'emoji': '💬',
      'rarity': 'common',
      'requiredValue': 1,
      'requirementType': 'chats',
    },
    'streak_7': {
      'title': 'Haftalik streak',
      'description': '7 kunlik streakga erishing',
      'emoji': '🔥',
      'rarity': 'rare',
      'requiredValue': 7,
      'requirementType': 'streak',
    },
    'streak_30': {
      'title': 'Oylik streak',
      'description': '30 kunlik streakga erishing',
      'emoji': '🏆',
      'rarity': 'epic',
      'requiredValue': 30,
      'requirementType': 'streak',
    },
    'level_5': {
      'title': 'Boshlang\'ich',
      'description': '5-darajaga erishing',
      'emoji': '⭐',
      'rarity': 'common',
      'requiredValue': 5,
      'requirementType': 'level',
    },
    'level_10': {
      'title': 'Rivojlangan',
      'description': '10-darajaga erishing',
      'emoji': '🌟',
      'rarity': 'rare',
      'requiredValue': 10,
      'requirementType': 'level',
    },
    'missions_50': {
      'title': 'Vazifa bajaruvchi',
      'description': '50 ta vazifani tugating',
      'emoji': '🎯',
      'rarity': 'epic',
      'requiredValue': 50,
      'requirementType': 'missions',
    },
    'xp_1000': {
      'title': 'XP yig\'uvchi',
      'description': '1000 XP yig\'ing',
      'emoji': '💎',
      'rarity': 'rare',
      'requiredValue': 1000,
      'requirementType': 'xp',
    },
    'xp_10000': {
      'title': 'XP ustasi',
      'description': '10,000 XP yig\'ing',
      'emoji': '👑',
      'rarity': 'legendary',
      'requiredValue': 10000,
      'requirementType': 'xp',
    },
  };

  // ─── Default Missions ───
  static const List<Map<String, dynamic>> defaultMissions = [
    {
      'title': '20 ta yangi so\'z o\'rganing',
      'description': 'Bugun 20 ta yangi so\'z o\'rganing',
      'emoji': '📚',
      'category': 'learning',
      'difficulty': 'easy',
      'xpReward': 10,
      'estimatedMinutes': 30,
      'isPremium': false,
    },
    {
      'title': '30 daqiqa kitob o\'qing',
      'description': 'Sevimli kitobingizdan 30 daqiqa o\'qing',
      'emoji': '📖',
      'category': 'reading',
      'difficulty': 'medium',
      'xpReward': 15,
      'estimatedMinutes': 30,
      'isPremium': false,
    },
    {
      'title': '15 daqiqa meditatsiya qiling',
      'description': 'Tinchlik va huzur topish uchun meditatsiya',
      'emoji': '🧘',
      'category': 'health',
      'difficulty': 'easy',
      'xpReward': 10,
      'estimatedMinutes': 15,
      'isPremium': false,
    },
    {
      'title': '1 ta ta\'limiy video yozing',
      'description': 'O\'z bilimingizni boshqalar bilan baham ko\'ring',
      'emoji': '🎬',
      'category': 'creative',
      'difficulty': 'hard',
      'xpReward': 25,
      'estimatedMinutes': 60,
      'isPremium': false,
    },
    {
      'title': 'Yangi ko\'nikma sinab ko\'ring',
      'description': 'Bugun yangi ko\'nikmani sinab ko\'ring',
      'emoji': '🔧',
      'category': 'productivity',
      'difficulty': 'medium',
      'xpReward': 15,
      'estimatedMinutes': 45,
      'isPremium': false,
    },
    {
      'title': 'Mashq qiling',
      'description': '30 daqiqa jismoniy mashq qiling',
      'emoji': '💪',
      'category': 'health',
      'difficulty': 'medium',
      'xpReward': 15,
      'estimatedMinutes': 30,
      'isPremium': false,
    },
    {
      'title': 'Do\'stingizga yordam bering',
      'description': 'Bir do\'stingizga yordam bering',
      'emoji': '🤝',
      'category': 'social',
      'difficulty': 'easy',
      'xpReward': 10,
      'estimatedMinutes': 30,
      'isPremium': false,
    },
    {
      'title': '1 ta blog yozing',
      'description': 'O\'z tajribangiz haqida blog yozing',
      'emoji': '✍️',
      'category': 'creative',
      'difficulty': 'hard',
      'xpReward': 30,
      'estimatedMinutes': 60,
      'isPremium': false,
    },
  ];

  // ─── Motivation Quotes (Uzbek) ───
  static const List<String> motivationQuotes = [
    'Har bir kichik qadam kelajakdagi katta muvaffaqiyatga olib keladi.',
    'Bugun qilgan harakatingiz ertaga mevasini beradi.',
    'O\'zingizga ishoning, siz qodirsiz!',
    'Muvaffaqiyat — bu har kuni kichik qadamlar bilan yurish.',
    'Orzularingizga intiling, hech qachon to\'xtamang.',
    'Bugun o\'zingizni yaxshilash uchun eng yaxshi kun.',
    'Bilim — bu kuch, o\'rganishni hech qachon to\'xtatmang.',
    'Har qiyinchilik — bu o\'sish imkoniyati.',
  ];
}
