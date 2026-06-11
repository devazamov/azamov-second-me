/// ═══════════════════════════════════════════════════════════════
/// Focus Timer Model - AZAMOV Second Me
/// Pomodoro/ Focus session tracking
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum FocusSessionStatus { running, paused, completed, cancelled }

class FocusSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final int actualMinutes; // How many minutes actually focused
  final String? taskName;
  final FocusSessionStatus status;
  final bool isBreak;

  const FocusSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.actualMinutes = 0,
    this.taskName,
    this.status = FocusSessionStatus.running,
    this.isBreak = false,
  });

  bool get isCompleted => status == FocusSessionStatus.completed;

  factory FocusSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FocusSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      durationMinutes: data['durationMinutes'] ?? 25,
      actualMinutes: data['actualMinutes'] ?? 0,
      taskName: data['taskName'],
      status: FocusSessionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => FocusSessionStatus.completed,
      ),
      isBreak: data['isBreak'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'actualMinutes': actualMinutes,
      'taskName': taskName,
      'status': status.name,
      'isBreak': isBreak,
    };
  }
}
