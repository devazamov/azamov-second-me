/// ═══════════════════════════════════════════════════════════════
/// Reminder Provider - AZAMOV Academy
/// Local notification reminders for habits, journal, missions
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderSettings {
  final bool journalReminder;
  final bool habitReminder;
  final bool missionReminder;
  final bool moodReminder;
  final String journalTime;
  final String habitTime;
  final String missionTime;
  final String moodTime;

  const ReminderSettings({
    this.journalReminder = false,
    this.habitReminder = false,
    this.missionReminder = false,
    this.moodReminder = false,
    this.journalTime = '20:00',
    this.habitTime = '09:00',
    this.missionTime = '10:00',
    this.moodTime = '19:00',
  });

  ReminderSettings copyWith({
    bool? journalReminder, bool? habitReminder, bool? missionReminder, bool? moodReminder,
    String? journalTime, String? habitTime, String? missionTime, String? moodTime,
  }) {
    return ReminderSettings(
      journalReminder: journalReminder ?? this.journalReminder,
      habitReminder: habitReminder ?? this.habitReminder,
      missionReminder: missionReminder ?? this.missionReminder,
      moodReminder: moodReminder ?? this.moodReminder,
      journalTime: journalTime ?? this.journalTime,
      habitTime: habitTime ?? this.habitTime,
      missionTime: missionTime ?? this.missionTime,
      moodTime: moodTime ?? this.moodTime,
    );
  }
}

final reminderSettingsProvider = StateNotifierProvider<ReminderNotifier, ReminderSettings>((ref) {
  return ReminderNotifier();
});

class ReminderNotifier extends StateNotifier<ReminderSettings> {
  ReminderNotifier() : super(const ReminderSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = ReminderSettings(
      journalReminder: prefs.getBool('reminder_journal') ?? false,
      habitReminder: prefs.getBool('reminder_habit') ?? false,
      missionReminder: prefs.getBool('reminder_mission') ?? false,
      moodReminder: prefs.getBool('reminder_mood') ?? false,
      journalTime: prefs.getString('reminder_journal_time') ?? '20:00',
      habitTime: prefs.getString('reminder_habit_time') ?? '09:00',
      missionTime: prefs.getString('reminder_mission_time') ?? '10:00',
      moodTime: prefs.getString('reminder_mood_time') ?? '19:00',
    );
  }

  Future<void> updateSettings(ReminderSettings settings) async {
    state = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_journal', settings.journalReminder);
    await prefs.setBool('reminder_habit', settings.habitReminder);
    await prefs.setBool('reminder_mission', settings.missionReminder);
    await prefs.setBool('reminder_mood', settings.moodReminder);
    await prefs.setString('reminder_journal_time', settings.journalTime);
    await prefs.setString('reminder_habit_time', settings.habitTime);
    await prefs.setString('reminder_mission_time', settings.missionTime);
    await prefs.setString('reminder_mood_time', settings.moodTime);
  }
}
