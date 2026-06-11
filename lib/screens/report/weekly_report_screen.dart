/// ═══════════════════════════════════════════════════════════════
/// Weekly Report - AZAMOV Academy
/// AI tomonidan yaratilgan haftalik hisobot
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/mission_provider.dart';
import '../../providers/focus_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/robot_avatar.dart';

class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  String? _report;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final weeklyProgress = ref.watch(weeklyProgressProvider);
    final weeklyStats = ref.watch(weeklyFocusStatsProvider);
    final habits = ref.watch(habitsWithStatusProvider);
    final missions = ref.watch(todayCompletedMissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Haftalik Hisobot 📊',
                style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 28,
                  fontWeight: FontWeight.w700, letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${DateTime.now().subtract(const Duration(days: 7)).day} - ${DateTime.now().day} ${_monthName(DateTime.now().month)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Stats cards
              Row(
                children: [
                  Expanded(child: _StatItem(
                    emoji: '⭐', value: '${user.valueOrNull?.xp ?? 0}', label: 'Jami XP',
                    color: AppColors.academyBlue,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatItem(
                    emoji: '🔥', value: '${user.valueOrNull?.currentStreak ?? 0}', label: 'Streak',
                    color: AppColors.warning,
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _StatItem(
                    emoji: '🎯', value: '${missions.valueOrNull?.length ?? 0}', label: 'Vazifalar',
                    color: AppColors.success,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatItem(
                    emoji: '⏱️', value: '${weeklyStats.valueOrNull?['sessions'] ?? 0}', label: 'Fokus',
                    color: AppColors.academyPurple,
                  )),
                ],
              ),

              const SizedBox(height: 24),

              // Generate report button
              if (_report == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : () => _generateReport(),
                    icon: _isGenerating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(_isGenerating ? 'Yaratilmoqda...' : 'AI Hisobotni yaratish'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                  ),
                ),

              if (_isGenerating)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (_report != null) ...[
                // AI Report content
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const RobotAvatar(size: 40, animation: RobotAnimation.happy, showGlow: false),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('AI Hisobot',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _report = null),
                            child: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(_report!,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Progress chart
              const Text('Haftalik faollik',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: weeklyProgress.when(
                  data: (progress) {
                    if (progress.isEmpty) {
                      return const SizedBox(height: 150, child: Center(child: Text('Ma\'lumot yo\'q', style: TextStyle(color: AppColors.textMuted))));
                    }
                    return SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (g, i, r, j) => BarTooltipItem('${r.toY.toInt()} XP', const TextStyle(color: Colors.white)),
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
                                getTitlesWidget: (v, m) {
                                  final days = ['Du','Se','Ch','Pa','Ju','Sh','Ya'];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(days[v.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: List.generate(7, (i) {
                            double v = i < progress.length ? progress[i].xpEarned.toDouble() : 0;
                            return BarChartGroupData(x: i, barRods: [
                              BarChartRodData(toY: v, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                color: v > 0 ? AppColors.academyBlue : AppColors.silverLight),
                            ]);
                          }),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => SizedBox(height: 150, child: Center(child: Text('Xatolik: $e'))),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final weeklyData = await ref.read(weeklyProgressProvider.future);
    final habitsData = ref.read(habitsWithStatusProvider).valueOrNull ?? [];
    final missionsData = ref.read(todayCompletedMissionsProvider).valueOrNull ?? [];
    final focusData = ref.read(weeklyFocusStatsProvider).valueOrNull ?? {};

    final data = {
      'totalXp': weeklyData.fold<int>(0, (s, p) => s + p.xpEarned),
      'completedMissions': missionsData.length,
      'chatsHad': weeklyData.fold<int>(0, (s, p) => s + p.chatsHad),
      'habitsDone': habitsData.where((h) => h['isDone'] as bool).length,
      'totalHabits': habitsData.length,
      'focusSessions': focusData['sessions'] ?? 0,
      'journalEntries': 0,
    };

    final aiService = AiService();
    final report = await aiService.generateWeeklyReport(user, data);
    if (mounted) setState(() { _report = report; _isGenerating = false; });
  }

  String _monthName(int m) {
    const months = ['Yanvar','Fevral','Mart','Aprel','May','Iyun','Iyul','Avgust','Sentabr','Oktabr','Noyabr','Dekabr'];
    return months[m - 1];
  }
}

class _StatItem extends StatelessWidget {
  final String emoji, value, label;
  final Color color;

  const _StatItem({required this.emoji, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
