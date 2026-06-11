/// ═══════════════════════════════════════════════════════════════
/// Focus Timer Screen - AZAMOV Second Me
/// Pomodoro timer with session tracking
/// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/focus_provider.dart';
import '../../models/focus_model.dart';
import '../../widgets/glass_card.dart';

class FocusTimerScreen extends ConsumerWidget {
  const FocusTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(focusTimerNotifierProvider);
    final todaySessions = ref.watch(todayFocusSessionsProvider);
    final weeklyStats = ref.watch(weeklyFocusStatsProvider);

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
                'Focus Timer ⏱️',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pomodoro texnikasi bilan diqqatingizni jamlang',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // ─── Timer Circle ───
              Center(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress ring
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: timerState.progress,
                          strokeWidth: 10,
                          backgroundColor: AppColors.silverLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            timerState.status == TimerStatus.breakTime
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Timer text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status label
                          Text(
                            _statusLabel(timerState.status),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            timerState.formattedTime,
                            style: TextStyle(
                              color: timerState.status == TimerStatus.breakTime
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                              fontSize: 52,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          if (timerState.taskName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              timerState.taskName!,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Timer Controls ───
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (timerState.status == TimerStatus.idle ||
                      timerState.status == TimerStatus.completed) ...[
                    // Start buttons
                    _TimerButton(
                      icon: Icons.play_arrow_rounded,
                      label: '25 min',
                      color: AppColors.primary,
                      onTap: () => ref
                          .read(focusTimerNotifierProvider.notifier)
                          .startPomodoro(),
                    ),
                    const SizedBox(width: 12),
                    _TimerButton(
                      icon: Icons.timer_rounded,
                      label: 'Tanlash',
                      color: AppColors.textSecondary,
                      onTap: () => _showDurationPicker(context, ref),
                    ),
                  ] else if (timerState.status == TimerStatus.running) ...[
                    _TimerButton(
                      icon: Icons.pause_rounded,
                      label: 'Pauza',
                      color: AppColors.warning,
                      onTap: () => ref
                          .read(focusTimerNotifierProvider.notifier)
                          .pauseTimer(),
                    ),
                    const SizedBox(width: 12),
                    _TimerButton(
                      icon: Icons.stop_rounded,
                      label: 'To\'xtat',
                      color: AppColors.error,
                      onTap: () => ref
                          .read(focusTimerNotifierProvider.notifier)
                          .stopTimer(),
                    ),
                  ] else if (timerState.status == TimerStatus.paused) ...[
                    _TimerButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Davom',
                      color: AppColors.primary,
                      onTap: () => ref
                          .read(focusTimerNotifierProvider.notifier)
                          .resumeTimer(),
                    ),
                    const SizedBox(width: 12),
                    _TimerButton(
                      icon: Icons.stop_rounded,
                      label: 'To\'xtat',
                      color: AppColors.error,
                      onTap: () => ref
                          .read(focusTimerNotifierProvider.notifier)
                          .stopTimer(),
                    ),
                  ] else if (timerState.status == TimerStatus.breakTime) ...[
                    _TimerButton(
                      icon: Icons.skip_next_rounded,
                      label: 'Skip',
                      color: AppColors.primary,
                      onTap: () => ref
                          .read(focusTimerNotifierProvider.notifier)
                          .stopTimer(),
                    ),
                    const SizedBox(width: 12),
                    _TimerButton(
                      icon: Icons.pause_rounded,
                      label: 'Pauza',
                      color: AppColors.warning,
                      onTap: () => ref
                          .read(focusTimerNotifierProvider.notifier)
                          .pauseTimer(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // ─── Sessions Counter ───
              if (timerState.completedSessions > 0)
                Center(
                  child: Text(
                    '${timerState.completedSessions} ta session bajarildi',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ─── Today's Stats ───
              const Text(
                'Bugungi statistika',
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
                    child: _buildStatsCard(
                      todaySessions,
                      weeklyStats,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Pomodoro Tips ───
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pomodoro texnikasi',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '25 daqiqa ish → 5 daqiqa dam\nHar 4 sikl → 15 daqiqa uzun dam',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildStatsCard(
    AsyncValue<List<FocusSession>> todaySessions,
    AsyncValue<Map<String, dynamic>> weeklyStats,
  ) {
    final sessions = todaySessions.valueOrNull ?? [];
    final stats = weeklyStats.valueOrNull ?? {'sessions': 0, 'totalMinutes': 0};
    final completedToday = sessions.where((s) => s.isCompleted).length;
    final todayMinutes =
        sessions.where((s) => s.isCompleted).fold<int>(0, (sum, s) => sum + s.actualMinutes);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text('Bugun', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '$completedToday',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'sessiya',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.silverLight),
          Expanded(
            child: Column(
              children: [
                const Text('Vaqt', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${stats['totalMinutes']}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'daqiqa',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(TimerStatus status) {
    switch (status) {
      case TimerStatus.idle:
        return 'Tayyor';
      case TimerStatus.running:
        return 'Diqqat!';
      case TimerStatus.paused:
        return 'Pauza';
      case TimerStatus.breakTime:
        return 'Dam olish';
      case TimerStatus.completed:
        return 'Bajarildi!';
    }
  }

  void _showDurationPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.silverLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Vaqtni tanlang',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ...[10, 15, 25, 30, 45, 60].map((minutes) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      '$minutes daqiqa',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: minutes == 25
                        ? const Icon(Icons.check_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      ref
                          .read(focusTimerNotifierProvider.notifier)
                          .startTimer(minutes: minutes);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

/// ─── Timer Control Button ───
class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
