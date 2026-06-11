/// ═══════════════════════════════════════════════════════════════
/// Missions Screen - AZAMOV Second Me
/// Daily personalized missions with XP rewards
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/mission_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/mission_model.dart';
import '../../widgets/glass_card.dart';

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider);
    final completedToday = ref.watch(todayCompletedMissionsProvider);
    final missionState = ref.watch(missionNotifierProvider);

    // Show completion dialog
    ref.listen<MissionState>(missionNotifierProvider, (prev, next) {
      if (next.justCompleted != null && next.justCompleted != prev?.justCompleted) {
        _showCompletionDialog(context, next.justCompleted!);
        ref.read(missionNotifierProvider.notifier).clearJustCompleted();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                'Vazifalar 🎯',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // ─── Today's Progress ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: completedToday.when(
                  data: (completed) {
                    final totalXp = completed.fold<int>(
                      0,
                      (sum, m) => sum + m.xpEarned,
                    );
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bugungi yutuqlar',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${completed.length} vazifa • $totalXp XP',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const SizedBox(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Missions List ───
            Expanded(
              child: missions.when(
                data: (missionList) {
                  if (missionList.isEmpty) {
                    return const Center(
                      child: Text(
                        'Hozircha vazifalar yo\'q',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: missionList.length,
                    itemBuilder: (context, index) {
                      final mission = missionList[index];
                      return _MissionCard(
                        mission: mission,
                        isCompleting: missionState.isCompleting,
                        onComplete: () {
                          ref
                              .read(missionNotifierProvider.notifier)
                              .completeMission(mission);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('Xatolik: $e'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, Mission mission) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Celebration Emoji ───
              Text(
                mission.emoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tabriklaymiz! 🎉',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mission.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),

              // ─── XP Badge ───
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${mission.totalXp} XP',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Davom et'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── Mission Card ───
class _MissionCard extends StatelessWidget {
  final Mission mission;
  final bool isCompleting;
  final VoidCallback onComplete;

  const _MissionCard({
    required this.mission,
    required this.isCompleting,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ─── Emoji ───
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  mission.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ─── Info ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatusBadge(
                        label: mission.difficulty.name,
                        color: _difficultyColor(mission.difficulty),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${mission.timeEstimate}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Complete Button ───
            GestureDetector(
              onTap: isCompleting ? null : onComplete,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isCompleting ? null : AppColors.primaryGradient,
                  color: isCompleting ? AppColors.silverLight : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isCompleting
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: isCompleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textMuted,
                          ),
                        )
                      : const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.easy:
        return AppColors.success;
      case MissionDifficulty.medium:
        return AppColors.warning;
      case MissionDifficulty.hard:
        return AppColors.error;
    }
  }
}
