/// ═══════════════════════════════════════════════════════════════
/// Home Screen - AZAMOV Second Me
/// Personalized greeting, streak, daily mission, progress summary
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/mission_provider.dart';
import '../../widgets/glass_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️ Xayrli ertalab';
    if (hour < 17) return '🌤️ Xayrli kun';
    if (hour < 21) return '🌅 Xayrli kech';
    return '🌙 Xayrli tun';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final missions = ref.watch(missionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentUserProvider);
            ref.invalidate(missionsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ─── App Bar ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.valueOrNull?.name ?? 'Foydalanuvchi',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              (user.valueOrNull?.name ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Stats Row ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Streak',
                          value: '${user.valueOrNull?.currentStreak ?? 0}',
                          icon: Icons.local_fire_department_rounded,
                          color: AppColors.warning,
                          subtitle: 'kun',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Level',
                          value: '${user.valueOrNull?.level ?? 1}',
                          icon: Icons.trending_up_rounded,
                          color: AppColors.primary,
                          subtitle: '${user.valueOrNull?.xp ?? 0} XP',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Level Progress ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Keyingi levelgacha',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${((user.valueOrNull?.levelProgress ?? 0) * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: user.valueOrNull?.levelProgress ?? 0,
                            backgroundColor: AppColors.silverLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Daily Missions Preview ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bugungi vazifalar',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/missions'),
                        child: const Text(
                          'Barchasini ko\'rish',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Mission Cards ───
              missions.when(
                data: (missionList) {
                  final displayMissions = missionList.take(3).toList();
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final mission = displayMissions[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                          child: GlassCard(
                            onTap: () => context.go('/missions'),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      mission.emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mission.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${mission.timeEstimate} • ${mission.totalXp} XP',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(
                                  label: mission.difficulty.name,
                                  color: mission.difficulty.name == 'easy'
                                      ? AppColors.success
                                      : mission.difficulty.name == 'medium'
                                          ? AppColors.warning
                                          : AppColors.error,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: displayMissions.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text('Xatolik: $e'),
                    ),
                  ),
                ),
              ),

              // ─── Future Self Shortcut ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: GlassCard(
                    onTap: () => context.go('/chat'),
                    borderColor: AppColors.primary.withOpacity(0.2),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.accent.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kelajakdagi o\'zing bilan gaplash',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'AI sizning kelajak versiyangiz',
                                  style: TextStyle(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Quick Actions Grid ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tezkor amallar',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              emoji: '📋',
                              title: 'Odatlar',
                              subtitle: 'Kunlik odatlar',
                              color: AppColors.primary,
                              onTap: () => context.go('/habits'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickActionCard(
                              emoji: '📝',
                              title: 'Kundalik',
                              subtitle: 'Fikrlarni yozish',
                              color: AppColors.success,
                              onTap: () => context.go('/journal'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              emoji: '⏱️',
                              title: 'Focus',
                              subtitle: 'Pomodoro taymer',
                              color: AppColors.warning,
                              onTap: () => context.go('/focus'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickActionCard(
                              emoji: '😊',
                              title: 'Kayfiyat',
                              subtitle: 'Kayfiyatni kuzatish',
                              color: AppColors.error,
                              onTap: () => context.go('/mood'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              emoji: '🏆',
                              title: 'Challenge',
                              subtitle: 'Haftalik challenge',
                              color: const Color(0xFF6366F1),
                              onTap: () => context.go('/challenge'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── Quick Action Card ───
class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}