/// ═══════════════════════════════════════════════════════════════
/// Mood Tracker Screen - AZAMOV Second Me
/// Track daily mood with emoji picker and history chart
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../providers/mood_provider.dart';
import '../../models/mood_model.dart';
import '../../widgets/glass_card.dart';

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen> {
  final _noteController = TextEditingController();
  List<EmotionTag> _selectedEmotions = [];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayMood = ref.watch(todayMoodProvider);
    final moodHistory = ref.watch(moodHistoryProvider);

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
                'Kayfiyat 😊',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kundalik kayfiyatingizni kuzatib boring',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // ─── Today's Mood ───
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Bugungi kayfiyatingiz qanday?',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Mood Emoji Grid ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: MoodLevel.values.map((level) {
                        final todayEntry = todayMood.valueOrNull;
                        final isSelected = todayEntry?.moodLevel == level;

                        return GestureDetector(
                          onTap: () => _logMood(level),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.silverLight,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.2),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  level.emoji,
                                  style: TextStyle(
                                    fontSize: isSelected ? 36 : 30,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _moodLabel(level),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ─── Emotions Tags ───
                    const Text(
                      'Qanday his qilyapsiz?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: EmotionTag.values.map((emotion) {
                        final isSelected = _selectedEmotions.contains(emotion);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedEmotions.remove(emotion);
                              } else {
                                _selectedEmotions.add(emotion);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.silverLight,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(emotion.emoji, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  emotion.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight:
                                        isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // ─── Note ───
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.silverLight),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Bugungi kayfiyatingiz haqida izoh...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Save Button ───
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final selectedLevel = todayMood.valueOrNull?.moodLevel;
                          if (selectedLevel != null) {
                            ref.read(moodNotifierProvider.notifier).logMood(
                                  moodLevel: selectedLevel,
                                  emotions: _selectedEmotions,
                                  note: _noteController.text.trim().isNotEmpty
                                      ? _noteController.text.trim()
                                      : null,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kayfiyat saqlandi! 😊')),
                            );
                          }
                        },
                        child: const Text('Saqlash'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Mood History Chart ───
              const Text(
                '30 kunlik tarix',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              GlassCard(
                padding: const EdgeInsets.all(16),
                child: moodHistory.when(
                  data: (history) {
                    if (history.isEmpty) {
                      return const SizedBox(
                        height: 160,
                        child: Center(
                          child: Text(
                            'Hozircha ma\'lumot yo\'q',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 160,
                      child: _MoodChart(history: history),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SizedBox(
                    height: 160,
                    child: Center(child: Text('Xatolik: $e')),
                  ),
                ),
              ),

              // ─── Weekly Average ───
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: AppColors.info,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Haftalik o\'rtacha',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _averageMoodLabel(
                              ref.watch(weeklyMoodAverageProvider),
                            ),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _averageMoodEmoji(ref.watch(weeklyMoodAverageProvider)),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _logMood(MoodLevel level) {
    ref.read(moodNotifierProvider.notifier).logMood(
          moodLevel: level,
          emotions: _selectedEmotions,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );
  }

  String _moodLabel(MoodLevel level) {
    switch (level) {
      case MoodLevel.amazing:
        return 'Ajoyib';
      case MoodLevel.good:
        return 'Yaxshi';
      case MoodLevel.neutral:
        return 'Normal';
      case MoodLevel.bad:
        return 'Yomon';
      case MoodLevel.terrible:
        return 'Juda yomon';
    }
  }

  String _averageMoodLabel(double avg) {
    if (avg >= 0.8) return 'Ajoyib hafta!';
    if (avg >= 0.6) return 'Yaxshi hafta';
    if (avg >= 0.4) return 'O\'rtacha hafta';
    if (avg >= 0.2) return 'Qiyin hafta';
    return 'Og\'ir hafta';
  }

  String _averageMoodEmoji(double avg) {
    if (avg >= 0.8) return '😄';
    if (avg >= 0.6) return '🙂';
    if (avg >= 0.4) return '😐';
    if (avg >= 0.2) return '😞';
    return '😢';
  }
}

/// ─── Mood History Chart ───
class _MoodChart extends StatelessWidget {
  final List<MoodEntry> history;

  const _MoodChart({required this.history});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: -0.1,
        maxY: 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(history.length, (index) {
              return FlSpot(index.toDouble(), history[index].moodLevel.value);
            }),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
