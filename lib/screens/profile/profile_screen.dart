/// ═══════════════════════════════════════════════════════════════
/// Profile Screen - AZAMOV Academy
/// User info, settings, dark mode, language, reminders
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/robot_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userData = user.valueOrNull;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final locale = ref.watch(localeProvider);
    final reminders = ref.watch(reminderSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profil 👤',
                    style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 28,
                      fontWeight: FontWeight.w700, letterSpacing: -0.5,
                    ),
                  ),
                  const RobotAvatar(size: 36, animation: RobotAnimation.happy, showGlow: false),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Profile Card ───
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: AppColors.academyBlue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: Text(
                          (userData?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(userData?.name ?? 'Foydalanuvchi',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(userData?.email ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${userData?.age ?? 0} yosh • ${userData?.gender ?? ''}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Premium Card ───
              if (userData?.isPremium == true)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(gradient: AppColors.premiumGradient, borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(16),
                    child: const Row(children: [
                      Icon(Icons.diamond_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Premium a\'zo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('Cheksiz AI chat va maxsus imkoniyatlar', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ])),
                    ]),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => context.go('/premium'),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(gradient: AppColors.premiumGradient, borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(20),
                      child: const Row(children: [
                        Icon(Icons.diamond_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Premiumga o\'ting', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          Text('49,000 so\'m/oy - Cheksiz imkoniyatlar', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ])),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                      ]),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ─── Dark Mode Toggle ───
              const Text('Ko\'rinish', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.academyBlue, size: 20),
                  const SizedBox(width: 14),
                  Expanded(child: Text(isDark ? 'Tun rejimi' : 'Kun rejimi',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15))),
                  Switch(
                    value: isDark,
                    onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                ]),
              ),
              const SizedBox(height: 8),

              // ─── Language Selector ───
              GlassCard(
                onTap: () => _showLanguagePicker(context, ref),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  const Icon(Icons.language_rounded, color: AppColors.academyBlue, size: 20),
                  const SizedBox(width: 14),
                  Expanded(child: Text('Til', style: const TextStyle(color: AppColors.textPrimary, fontSize: 15))),
                  Text(_langName(locale.languageCode), style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                ]),
              ),
              const SizedBox(height: 8),

              // ─── Reminders ───
              GlassCard(
                onTap: () => _showReminderSettings(context, ref),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  const Icon(Icons.notifications_rounded, color: AppColors.academyBlue, size: 20),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Eslatmalar', style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                    Text('${_countEnabled(reminders)} ta eslatma', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ])),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                ]),
              ),

              const SizedBox(height: 24),

              // ─── App Info ───
              const Text('Ilova', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.ac_unit_rounded, color: AppColors.academyBlue, size: 18),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AZAMOV Academy', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('v1.0.0 • Second Me', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ])),
                ]),
              ),
              const SizedBox(height: 8),
              GlassCard(
                onTap: () {},
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  const Icon(Icons.privacy_tip_rounded, color: AppColors.academyBlue, size: 20),
                  const SizedBox(width: 14),
                  const Expanded(child: Text('Maxfiylik siyosati', style: TextStyle(color: AppColors.textPrimary, fontSize: 15))),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                ]),
              ),
              const SizedBox(height: 8),
              GlassCard(
                onTap: () {},
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  const Icon(Icons.description_rounded, color: AppColors.academyBlue, size: 20),
                  const SizedBox(width: 14),
                  const Expanded(child: Text('Foydalanish shartlari', style: TextStyle(color: AppColors.textPrimary, fontSize: 15))),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                ]),
              ),

              const SizedBox(height: 24),

              // ─── Logout ───
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Chiqish'),
                        content: const Text('Hisobingizdan chiqmoqchimisiz?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor qilish')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Chiqish', style: TextStyle(color: AppColors.error))),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await ref.read(authServiceProvider).signOut();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text('Chiqish', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  int _countEnabled(ReminderSettings r) {
    return [r.journalReminder, r.habitReminder, r.missionReminder, r.moodReminder].where((b) => b).length;
  }

  String _langName(String code) {
    switch (code) { case 'uz': return 'O\'zbek'; case 'en': return 'English'; case 'ru': return 'Русский'; default: return 'O\'zbek'; }
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.silverLight, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('Tilni tanlang', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ...AppLanguage.supported.map((lang) => ListTile(
            leading: Text(lang.code == 'uz' ? '🇺🇿' : lang.code == 'en' ? '🇬🇧' : '🇷🇺', style: const TextStyle(fontSize: 24)),
            title: Text(lang.nativeName, style: const TextStyle(color: AppColors.textPrimary)),
            subtitle: Text(lang.name, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            trailing: ref.read(localeProvider).languageCode == lang.code
                ? const Icon(Icons.check_rounded, color: AppColors.academyBlue)
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(lang.code);
              Navigator.pop(ctx);
            },
          )),
        ]),
      ),
    );
  }

  void _showReminderSettings(BuildContext context, WidgetRef ref) {
    final reminders = ref.read(reminderSettingsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.silverLight, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Eslatmalar', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _reminderTile(ctx, '📝', 'Kundalik yozish', 'Kechki eslatma', reminders.journalReminder, (v) {
              final updated = reminders.copyWith(journalReminder: v);
              ref.read(reminderSettingsProvider.notifier).updateSettings(updated);
              setState(() {});
            }),
            _reminderTile(ctx, '✅', 'Odatlarni bajarish', 'Ertalabki eslatma', reminders.habitReminder, (v) {
              final updated = reminders.copyWith(habitReminder: v);
              ref.read(reminderSettingsProvider.notifier).updateSettings(updated);
              setState(() {});
            }),
            _reminderTile(ctx, '🎯', 'Vazifalarni tekshirish', 'Kunlik vazifalar', reminders.missionReminder, (v) {
              final updated = reminders.copyWith(missionReminder: v);
              ref.read(reminderSettingsProvider.notifier).updateSettings(updated);
              setState(() {});
            }),
            _reminderTile(ctx, '😊', 'Kayfiyatni belgilash', 'Kechki kayfiyat', reminders.moodReminder, (v) {
              final updated = reminders.copyWith(moodReminder: v);
              ref.read(reminderSettingsProvider.notifier).updateSettings(updated);
              setState(() {});
            }),
          ]),
        ),
      ),
    );
  }

  Widget _reminderTile(BuildContext ctx, String emoji, String title, String desc, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
          Text(desc, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ])),
        Switch(value: value, onChanged: onChanged),
      ]),
    );
  }
}
