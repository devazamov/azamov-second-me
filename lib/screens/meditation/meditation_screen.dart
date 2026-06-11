/// ═══════════════════════════════════════════════════════════════
/// Meditation & Breathing Guide - AZAMOV Academy
/// Nafas olish mashqlari va meditatsiya
/// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isActive = false;
  String _selectedExercise = 'box';
  String _phase = '';
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  final _exercises = {
    'box': {
      'name': 'Box Breathing',
      'emoji': '🟦',
      'description': '4-4-4-4 usuli: 4 soniya nafas, 4 ushlab tur, 4 chiqar, 4 dam',
      'pattern': [4, 4, 4, 4],
    },
    '478': {
      'name': '4-7-8 Relaxation',
      'emoji': '😌',
      'description': '4 soniya nafas olish, 7 soniya ushlab turish, 8 soniya chiqarish',
      'pattern': [4, 7, 8],
    },
    'simple': {
      'name': 'Oddiy nafas',
      'emoji': '🌊',
      'description': '4 soniya nafas olish, 6 soniya chiqarish',
      'pattern': [4, 6],
    },
  };

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  void _startExercise() {
    final pattern = _exercises[_selectedExercise]!['pattern'] as List<int>;
    final totalSeconds = pattern.fold<int>(0, (sum, s) => sum + s);
    _secondsRemaining = totalSeconds * 4; // 4 cycles
    _isActive = true;
    _runCycle(pattern);
  }

  void _runCycle(List<int> pattern) {
    _timer?.cancel();
    if (!_isActive || _secondsRemaining <= 0) {
      _stopExercise();
      return;
    }

    var stepIndex = 0;
    final phases = ['Nafas oling', 'Ushlab turing', 'Nafas chiqaring', 'Dam oling'];

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
        _phase = phases[stepIndex % phases.length];
      });

      if (_secondsRemaining <= 0) {
        _stopExercise();
      }
    });

    _breathController.repeat(reverse: true);
  }

  void _stopExercise() {
    _timer?.cancel();
    _breathController.stop();
    _breathController.reset();
    setState(() {
      _isActive = false;
      _phase = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meditatsiya 🧘',
                style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 28,
                  fontWeight: FontWeight.w700, letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nafas olish mashqlari bilan tinchlaning',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Exercise selector
              ..._exercises.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: () {
                    setState(() => _selectedExercise = entry.key);
                    _stopExercise();
                  },
                  padding: const EdgeInsets.all(16),
                  borderColor: _selectedExercise == entry.key
                      ? AppColors.academyBlue
                      : null,
                  child: Row(
                    children: [
                      Text(entry.value['emoji'] as String, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.value['name'] as String,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(entry.value['description'] as String,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      if (_selectedExercise == entry.key)
                        const Icon(Icons.check_circle_rounded, color: AppColors.academyBlue, size: 22),
                    ],
                  ),
                ),
              )),

              const SizedBox(height: 24),

              // Breathing circle
              Center(
                child: AnimatedBuilder(
                  animation: _breathAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.academyBlue.withOpacity(0.3),
                            AppColors.academyPurple.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Transform.scale(
                        scale: _isActive ? _breathAnimation.value : 0.7,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.academyBlue.withOpacity(0.15),
                            border: Border.all(
                              color: AppColors.academyBlue.withOpacity(0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.academyBlue.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isActive) ...[
                                  Text(_phase,
                                    style: const TextStyle(color: AppColors.academyBlue, fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700),
                                  ),
                                ] else
                                  const Text('🧘', style: TextStyle(fontSize: 64)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Start/Stop button
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: _isActive ? _stopExercise : _startExercise,
                    icon: Icon(_isActive ? Icons.stop_rounded : Icons.play_arrow_rounded),
                    label: Text(_isActive ? 'To\'xtatish' : 'Boshlash'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: _isActive ? AppColors.error : AppColors.academyBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tips
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
                      child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.info, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Maslahat',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text('Har kuni 5-10 daqiqa meditatsiya stressni kamaytiradi va diqqatni oshiradi',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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
}
