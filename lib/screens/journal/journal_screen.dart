/// ═══════════════════════════════════════════════════════════════
/// Journal Screen - AZAMOV Second Me
/// Daily reflections with mood, gratitudes, and goals
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_model.dart';
import '../../widgets/glass_card.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _contentController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _winController = TextEditingController();
  final _goalController = TextEditingController();
  JournalMood _selectedMood = JournalMood.neutral;
  List<String> _gratitudes = [];
  bool _isSaving = false;
  String? _entryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadToday());
  }

  Future<void> _loadToday() async {
    final entry = await ref.read(todayJournalProvider.future);
    if (entry != null && mounted) {
      setState(() {
        _entryId = entry.id;
        _contentController.text = entry.content;
        _selectedMood = entry.mood;
        _gratitudes = List.from(entry.gratitudes);
      });
    } else {
      final id = await ref.read(journalNotifierProvider.notifier).createNewEntry();
      if (mounted) setState(() => _entryId = id);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _gratitudeController.dispose();
    _winController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_entryId == null || _isSaving) return;
    setState(() => _isSaving = true);

    await ref.read(journalNotifierProvider.notifier).saveEntry(
          id: _entryId!,
          content: _contentController.text.trim(),
          mood: _selectedMood,
          gratitudes: _gratitudes,
          todayWin: _winController.text.trim().isNotEmpty
              ? _winController.text.trim()
              : null,
          tomorrowGoal: _goalController.text.trim().isNotEmpty
              ? _goalController.text.trim()
              : null,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kundalik saqlandi! 📝')),
      );
    }
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
              // ─── Header ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kundalik 📝',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    _formatDate(DateTime.now()),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Fikrlaringizni yozib boring, kelajakdagi suhbatlarda foydali bo\'ladi',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // ─── Mood Selector ───
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bugungi kayfiyatingiz?',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: JournalMood.values.map((mood) {
                        final isSelected = _selectedMood == mood;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMood = mood),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.silverLight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _moodEmoji(mood),
                                  style: TextStyle(
                                    fontSize: isSelected ? 28 : 24,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _moodLabel(mood),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Content ───
              const Text(
                'Bugun nima bo\'ldi?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.silverLight),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Bugungi fikrlaringiz, hissiyotlaringiz...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Gratitudes ───
              const Text(
                'Minnatdorchiliklar 🙏',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ..._gratitudes.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded,
                              color: AppColors.error, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              g,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(
                                () => _gratitudes.remove(g)),
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.textMuted, size: 18),
                          ),
                        ],
                      ),
                    ),
                  )),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.silverLight),
                      ),
                      child: TextField(
                        controller: _gratitudeController,
                        decoration: const InputDecoration(
                          hintText: 'Yangi minnatdorchilik...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              _gratitudes.add(value.trim());
                              _gratitudeController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final text = _gratitudeController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          _gratitudes.add(text);
                          _gratitudeController.clear();
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Today's Win ───
              const Text(
                'Bugungi yutuq 🏆',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.silverLight),
                ),
                child: TextField(
                  controller: _winController,
                  decoration: const InputDecoration(
                    hintText: 'Bugungi eng katta yutug\'ingiz...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Tomorrow's Goal ───
              const Text(
                'Ertangi maqsad 🎯',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.silverLight),
                ),
                child: TextField(
                  controller: _goalController,
                  decoration: const InputDecoration(
                    hintText: 'Ertaga nima qilmoqchisiz?',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ─── Save Button ───
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Saqlanmoqda...' : 'Saqlash'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _moodEmoji(JournalMood mood) {
    switch (mood) {
      case JournalMood.amazing:
        return '😄';
      case JournalMood.good:
        return '🙂';
      case JournalMood.neutral:
        return '😐';
      case JournalMood.bad:
        return '😞';
      case JournalMood.terrible:
        return '😢';
    }
  }

  String _moodLabel(JournalMood mood) {
    switch (mood) {
      case JournalMood.amazing:
        return 'Ajoyib';
      case JournalMood.good:
        return 'Yaxshi';
      case JournalMood.neutral:
        return 'Normal';
      case JournalMood.bad:
        return 'Yomon';
      case JournalMood.terrible:
        return 'Juda yomon';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return '${date.day}-${months[date.month - 1]}, ${date.year}';
  }
}
