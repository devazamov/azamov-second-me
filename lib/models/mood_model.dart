/// ═══════════════════════════════════════════════════════════════
/// Mood Model - AZAMOV Second Me
/// Track daily mood and emotions
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

/// Primary mood states
enum MoodLevel {
  amazing,
  good,
  neutral,
  bad,
  terrible;

  String get emoji {
    switch (this) {
      case MoodLevel.amazing:
        return '😄';
      case MoodLevel.good:
        return '🙂';
      case MoodLevel.neutral:
        return '😐';
      case MoodLevel.bad:
        return '😞';
      case MoodLevel.terrible:
        return '😢';
    }
  }

  double get value {
    switch (this) {
      case MoodLevel.amazing:
        return 1.0;
      case MoodLevel.good:
        return 0.75;
      case MoodLevel.neutral:
        return 0.5;
      case MoodLevel.bad:
        return 0.25;
      case MoodLevel.terrible:
        return 0.0;
    }
  }
}

/// Specific emotion tags
enum EmotionTag {
  happy,
  excited,
  grateful,
  calm,
  focused,
  tired,
  anxious,
  stressed,
  sad,
  angry,
  lonely,
  hopeful,
  motivated,
  inspired,
  bored;

  String get emoji {
    switch (this) {
      case EmotionTag.happy:
        return '😊';
      case EmotionTag.excited:
        return '🤩';
      case EmotionTag.grateful:
        return '🙏';
      case EmotionTag.calm:
        return '🧘';
      case EmotionTag.focused:
        return '🎯';
      case EmotionTag.tired:
        return '😴';
      case EmotionTag.anxious:
        return '😰';
      case EmotionTag.stressed:
        return '😫';
      case EmotionTag.sad:
        return '😢';
      case EmotionTag.angry:
        return '😠';
      case EmotionTag.lonely:
        return '🥺';
      case EmotionTag.hopeful:
        return '🌟';
      case EmotionTag.motivated:
        return '💪';
      case EmotionTag.inspired:
        return '✨';
      case EmotionTag.bored:
        return '🥱';
    }
  }

  String get label {
    switch (this) {
      case EmotionTag.happy:
        return 'Baxtli';
      case EmotionTag.excited:
        return 'Hayajonli';
      case EmotionTag.grateful:
        return 'Minnatdor';
      case EmotionTag.calm:
        return 'Tinch';
      case EmotionTag.focused:
        return 'Diqqatli';
      case EmotionTag.tired:
        return 'Charchagan';
      case EmotionTag.anxious:
        return 'Xavotirli';
      case EmotionTag.stressed:
        return 'Stressli';
      case EmotionTag.sad:
        return 'Xafa';
      case EmotionTag.angry:
        return 'Jahldor';
      case EmotionTag.lonely:
        return 'Yolg\'iz';
      case EmotionTag.hopeful:
        return 'Umidvor';
      case EmotionTag.motivated:
        return 'Motivatsiyali';
      case EmotionTag.inspired:
        return 'Ilhomlangan';
      case EmotionTag.bored:
        return 'Zerikkan';
    }
  }
}

class MoodEntry {
  final String id;
  final String userId;
  final DateTime date;
  final MoodLevel moodLevel;
  final List<EmotionTag> emotions;
  final String? note;
  final DateTime createdAt;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodLevel,
    this.emotions = const [],
    this.note,
    required this.createdAt,
  });

  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MoodEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      moodLevel: MoodLevel.values.firstWhere(
        (e) => e.name == data['moodLevel'],
        orElse: () => MoodLevel.neutral,
      ),
      emotions: (data['emotions'] as List<dynamic>?)
              ?.map((e) => EmotionTag.values.firstWhere(
                    (tag) => tag.name == e,
                    orElse: () => EmotionTag.happy,
                  ))
              .toList() ??
          [],
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'moodLevel': moodLevel.name,
      'emotions': emotions.map((e) => e.name).toList(),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
