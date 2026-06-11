/// ═══════════════════════════════════════════════════════════════
/// Progress Screen - AZAMOV Second Me
/// XP, Level, Charts, Achievements, Streak tracking
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/progress_provider.dart';
import '../../models/progress_model.dart';
import '../../widgets/glass_card.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final weeklyProgress = ref.watch(weeklyProgressProvider);
    final achievements = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              const Text(
                'Taraqqiyot 📊',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 24),

              // ─── Level Card ───
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Level Circle
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress circle
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: user.valueOrNull?.levelProgress ?? 0,
                              strokeWidth: 8,
                              backgroundColor: AppColors.silverLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lv.${user.valueOrNull?.level ?? 1}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${user.valueOrNull?.xp ?? 0} XP',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Keyingi levelgacha',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Stats Row ───
              Row(
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
                      title: 'Eng uzun streak',
                      value: '${user.valueOrNull?.longestStreak ?? 0}',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.success,
                      subtitle: 'kun',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Weekly Chart ───
              const Text(
                'Haftalik faollik',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              GlassCard(
                padding: const EdgeInsets.all(16),
                child: weeklyProgress.when(
                  data: (progress) {
                    if (progress.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Hozircha ma\'lumot yo\'q',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 200,
                      child: _WeeklyChart(progress: progress),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SizedBox(
                    height: 200,
                    child: Center(child: Text('Xatolik: $e')),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── Achievements ───
              const Text(
                'Yutuqlar',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              achievements.when(
                data: (achievementList) {
                  if (achievementList.isEmpty) {
                    return GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              '🏅',
                              style: TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Yutuqlaringiz shu yerda ko\'rinadi',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: achievementList.length,
                    itemBuilder: (context, index) {
                      final achievement = achievementList[index];
                      return AchievementBadge(
                        emoji: achievement.emoji,
                        title: achievement.title,
                        isUnlocked: achievement.isUnlocked,
                      );
                    },
                  );
                },
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Xatolik: $e'),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── Weekly Progress Chart ───
class _WeeklyChart extends StatelessWidget {
  final List<DailyProgress> progress;

  const _WeeklyChart({required this.progress});

  @override
  Widget build(BuildContext context) {
    final days = ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} XP',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[index],
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(7, (index) {
          double value = 0;
          if (index < progress.length) {
            value = (progress[index].xpEarned).toDouble();
          }
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                color: value > 0 ? AppColors.primary : AppColors.silverLight,
              ),
            ],
          );
        }),
      ),
    );
  }
}
