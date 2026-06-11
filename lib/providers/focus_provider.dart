/// ═══════════════════════════════════════════════════════════════
/// Focus Timer Provider - AZAMOV Second Me
/// Riverpod provider for Pomodoro/ Focus timer
/// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/focus_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

const _uuid = Uuid();

/// Timer state
enum TimerStatus { idle, running, paused, breakTime, completed }

class FocusTimerState {
  final TimerStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final int completedSessions;
  final String? taskName;
  final DateTime? startTime;
  final TimerStatus? prePauseStatus;

  const FocusTimerState({
    this.status = TimerStatus.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.completedSessions = 0,
    this.taskName,
    this.startTime,
    this.prePauseStatus,
  });

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  FocusTimerState copyWith({
    TimerStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
    int? completedSessions,
    String? taskName,
    DateTime? startTime,
    TimerStatus? prePauseStatus,
    bool clearPrePause = false,
  }) {
    return FocusTimerState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      completedSessions: completedSessions ?? this.completedSessions,
      taskName: taskName ?? this.taskName,
      startTime: startTime ?? this.startTime,
      prePauseStatus: clearPrePause ? null : (prePauseStatus ?? this.prePauseStatus),
    );
  }
}

/// Focus Timer notifier with Pomodoro logic
class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  final Ref ref;
  Timer? _timer;

  // Pomodoro defaults
  static const int _workDuration = 25 * 60; // 25 minutes
  static const int _shortBreak = 5 * 60; // 5 minutes
  static const int _longBreak = 15 * 60; // 15 minutes
  static const int _sessionsBeforeLongBreak = 4;

  FocusTimerNotifier(this.ref) : super(const FocusTimerState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer({int? minutes, String? taskName}) {
    final totalSec = (minutes ?? 25) * 60;

    state = state.copyWith(
      status: TimerStatus.running,
      remainingSeconds: totalSec,
      totalSeconds: totalSec,
      taskName: taskName,
      startTime: DateTime.now(),
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void startPomodoro({String? taskName}) {
    startTimer(minutes: 25, taskName: taskName);
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(
      status: TimerStatus.paused,
      prePauseStatus: state.status,
    );
  }

  void resumeTimer() {
    state = state.copyWith(
      status: state.prePauseStatus ?? TimerStatus.running,
      clearPrePause: true,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void stopTimer() async {
    _timer?.cancel();
    _timer = null;

    // Save session if had some time
    if (state.totalSeconds > 0 && state.startTime != null) {
      await _saveSession(FocusSessionStatus.cancelled);
    }

    state = const FocusTimerState(
      completedSessions: 0,
    );
  }

  void _onTick(Timer timer) {
    if (state.remainingSeconds <= 1) {
      // Timer completed
      _timer?.cancel();
      _timer = null;

      final isBreak = state.status == TimerStatus.breakTime;
      if (isBreak) {
        state = state.copyWith(
          status: TimerStatus.idle,
          remainingSeconds: 0,
        );
      } else {
        // Work session completed
        _saveSession(FocusSessionStatus.completed);
        final newCount = state.completedSessions + 1;

        // Start break
        final isLongBreak = newCount % _sessionsBeforeLongBreak == 0;
        final breakDuration = isLongBreak ? _longBreak : _shortBreak;

        state = state.copyWith(
          status: TimerStatus.breakTime,
          remainingSeconds: breakDuration,
          totalSeconds: breakDuration,
          completedSessions: newCount,
        );
        _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
      }
    } else {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    }
  }

  Future<void> _saveSession(FocusSessionStatus status) async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null) return;

    final actualMinutes = ((state.totalSeconds - state.remainingSeconds) / 60).round();
    final session = FocusSession(
      id: _uuid.v4(),
      userId: userId,
      startTime: state.startTime ?? DateTime.now(),
      endTime: DateTime.now(),
      durationMinutes: state.totalSeconds ~/ 60,
      actualMinutes: actualMinutes,
      taskName: state.taskName,
      status: status,
    );

    await firestore.saveFocusSession(session);

    if (status == FocusSessionStatus.completed) {
      await firestore.addXp(userId, 10);
      ref.invalidate(currentUserProvider);
    }
  }
}

/// Today's focus sessions
final todayFocusSessionsProvider = FutureProvider<List<FocusSession>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Future.value([]);
  return firestore.getTodayFocusSessions(userId);
});

/// Weekly focus stats
final weeklyFocusStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Future.value({'sessions': 0, 'totalMinutes': 0});

  return firestore.getWeeklyFocusSessions(userId).then((sessions) {
    final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.actualMinutes);
    return {
      'sessions': sessions.length,
      'totalMinutes': totalMinutes,
    };
  });
});

final focusTimerNotifierProvider = StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  return FocusTimerNotifier(ref);
});
