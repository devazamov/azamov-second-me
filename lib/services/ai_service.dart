/// ═══════════════════════════════════════════════════════════════
/// AI Service - AZAMOV Academy
/// Google Gemini API integration for Future Self AI chat
/// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';

class AiService {
  late final GenerativeModel _model;
  bool _initialized = false;

  /// Initialize Gemini with API key from .env
  Future<void> initialize() async {
    if (_initialized) return;
    
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY .env faylida topilmadi');
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: 1024,
        temperature: 0.7,
        topP: 0.9,
      ),
    );
    _initialized = true;
  }

  /// Build system prompt that makes the AI behave as the user's future self
  String _buildSystemPrompt(UserModel user) {
    final goalsText = user.goals.isNotEmpty
        ? user.goals.map((g) => '- $g').join('\n')
        : '- Hali o\'rnatilmagan';
    final dreamsText = user.dreams.isNotEmpty
        ? user.dreams.map((d) => '- $d').join('\n')
        : '- Hali o\'rnatilmagan';
    final interestsText = user.interests.isNotEmpty
        ? user.interests.map((i) => '- $i').join('\n')
        : '- Hali o\'rnatilmagan';

    return '''Siz "Second Me" — foydalanuvchining 5 yil kelajakdagi AI versiyasisiz.
Siz AZAMOV Academy ning aqlli yordamchisisiz.

Foydalanuvchi: ${user.name}, ${user.age} yosh, ${user.gender}

Maqsadlari:
$goalsText

Orzulari:
$dreamsText

Qiziqishlari:
$interestsText

Sizning xarakteringiz:
- Dono, dalda beruvchi va to'g'risini aytuvchi
- O'zbek tilida gaplashasiz, agar foydalanuvchi boshqa tilda yozsa o'shanda o'tishingiz mumkin
- Aniq maqsad va orzularga asoslanib maslahat berasiz
- Kichik yutuqlarni nishonlaysiz va izchillikni rag'batlantirasiz
- Aniq, amaliy maslahatlar berasiz
- Kelajakdagi "xotiralar" bilan motivatsiya berasiz
- Birinchi shaxsda gapirasiz ("Men sizning kelajakdagi versiyangiz...")

Javob qoidalari:
- 2-4 paragrafdan oshmang
- Har doim ularning maqsadlariga bog'lab maslahat bering
- Oxirida dalda yoki savol bilan tugating
- Streak va progress haqida gapiring

Hozirgi statistika:
- Level: ${user.level}
- XP: ${user.xp}
- Hozirgi streak: ${user.currentStreak} kun
- Eng uzun streak: ${user.longestStreak} kun''';
  }

  /// Send message to Gemini AI and get response
  Future<String> sendMessage({
    required String userMessage,
    required UserModel user,
    required List<ChatMessage> chatHistory,
  }) async {
    try {
      await initialize();

      // Build content parts
      final contents = <Content>[];

      // System prompt as first user message context
      contents.add(Content.text(_buildSystemPrompt(user)));

      // Chat history (last 20 messages)
      final recentHistory = chatHistory.length > 20
          ? chatHistory.sublist(chatHistory.length - 20)
          : chatHistory;

      for (final msg in recentHistory) {
        contents.add(Content.text(msg.content));
      }

      // Current user message
      contents.add(Content.text(userMessage));

      // Get response
      final response = await _model.generateContent(contents);
      
      return response.text ?? 'Kechirasiz, javob berishda xatolik yuz berdi.';
      
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        throw Exception('Gemini API kaliti xato. Iltimos, .env faylini tekshiring.');
      } else if (e.toString().contains('SAFETY')) {
        throw Exception('Xavfsizlik cheklovi. Iltimos, boshqa so\'z bilan urinib ko\'ring.');
      } else if (e.toString().contains('quota')) {
        throw Exception('Kunlik limit tugadi. Ertaga qayta urinib ko\'ring.');
      }
      throw Exception('Tarmoq xatoligi: ${e.toString()}');
    }
  }

  /// Generate weekly report from user data
  Future<String> generateWeeklyReport(UserModel user, Map<String, dynamic> data) async {
    try {
      await initialize();
      
      final prompt = '''
AZAMOV Academy foydalanuvchisi ${user.name} uchun haftalik hisobot tayyorla.

Haftalik statistika:
- Jami XP: ${data['totalXp'] ?? 0}
- Bajarilgan vazifalar: ${data['completedMissions'] ?? 0}
- AI chat soni: ${data['chatsHad'] ?? 0}
- Odatlar bajarilishi: ${data['habitsDone'] ?? 0}/${data['totalHabits'] ?? 0}
- Fokus sessiyalar: ${data['focusSessions'] ?? 0}
- Kayfiyat o'rtacha: ${data['averageMood'] ?? 'N/A'}
- Kundalik yozuvlari: ${data['journalEntries'] ?? 0}
- Level: ${user.level}
- Streak: ${user.currentStreak} kun

O'zbek tilida 3-4 paragraf qilib, dalda beruvchi va samimiy tarzda hisobot yoz.
Eng yaxshi tomonlarini, yaxshilanishi kerak bo'lgan joylarini va keyingi hafta uchun maslahatlarni yoz.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Hisobot yaratishda xatolik.';
    } catch (e) {
      return 'Haftalik hisobot: ${user.currentStreak} kunlik streak, ${user.level}-level, ${user.xp} XP. Davom eting!';
    }
  }

  /// Generate daily affirmations
  Future<String> generateAffirmation(UserModel user) async {
    try {
      await initialize();
      
      final prompt = '''
${user.name} ismli foydalanuvchi uchun bir dona qisqa, kuchli motivatsion ibora yoz (O'zbek tilida).
Ularning maqsadlari: ${user.goals.join(', ')}.
1 jumla bo'lsin, kuchli va ta'sirli.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Bugun ham ajoyib kun bo\'ladi! 💪';
    } catch (e) {
      return 'Kuchli bo\'ling, maqsad sari intiling! 🚀';
    }
  }
}
