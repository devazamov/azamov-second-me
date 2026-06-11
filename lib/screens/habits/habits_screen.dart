/// ═══════════════════════════════════════════════════════════════
/// Habits Screen - AZAMOV Second Me
/// Track daily habits with check-in system
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../providers/habit_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/habit_model.dart';
import '../../widgets/glass_card.dart';

const _uuid = Uuid();

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsWithStatus = ref.watch(habitsWithStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                'Odatlar 📋',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Har kuni kichik qadamlar bilan o\'zingizni yaxshilang',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Habits List ───
            Expanded(
              child: habitsWithStatus.when(
                data: (habits) {
                  if (habits.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.checklist_rounded,
                                color: AppColors.primary,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Hali odatlar yo\'q',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Yangi odat qo\'shish uchun + tugmasini bosing',
                              textAlign: TextAlign.center,
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

                  final totalDone = habits.where((h) => h['isDone'] as bool).length;
                  final totalHabits = habits.length;

                  return Column(
                    children: [
                      // ─── Progress Summary ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
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
                                      'Bugungi taraqqiyot',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$totalDone / $totalHabits bajarildi',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 44,
                                height: 44,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: CircularProgressIndicator(
                                        value: totalHabits > 0 ? totalDone / totalHabits : 0,
                                        strokeWidth: 4,
                                        backgroundColor: AppColors.silverLight,
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          AppColors.success,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${totalHabits > 0 ? (totalDone / totalHabits * 100).round() : 0}%',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Habits ───
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: habits.length + 1, // +1 for add button
                          itemBuilder: (context, index) {
                            if (index == habits.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 24),
                                child: _AddHabitButton(
                                  onTap: () => _showAddHabitDialog(context, ref),
                                ),
                              );
                            }
                            final item = habits[index];
                            final habit = item['habit'] as Habit;
                            final isDone = item['isDone'] as bool;
                            final doneCount = item['doneCount'] as int;
                            final targetCount = item['targetCount'] as int;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GlassCard(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    // ─── Emoji Icon ───
                                    GestureDetector(
                                      onTap: () => ref.read(habitNotifierProvider.notifier).toggleHabit(habit),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isDone ? AppColors.successLight : AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: isDone
                                              ? const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: AppColors.success,
                                                  size: 28,
                                                )
                                              : Text(
                                                  habit.emoji,
                                                  style: const TextStyle(fontSize: 24),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // ─── Habit Info ───
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            habit.title,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              decoration: isDone ? TextDecoration.lineThrough : null,
                                              decorationColor: AppColors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          if (targetCount > 1)
                                            Text(
                                              '$doneCount / $targetCount marta',
                                              style: TextStyle(
                                                color: isDone ? AppColors.success : AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // ─── Check Button ───
                                    if (!isDone)
                                      GestureDetector(
                                        onTap: () => ref.read(habitNotifierProvider.notifier).toggleHabit(habit),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.silverLight,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.check_rounded,
                                              color: AppColors.textMuted,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Xatolik: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    String selectedEmoji = '✅';
    HabitCategory selectedCategory = HabitCategory.productivity;
    HabitFrequency selectedFrequency = HabitFrequency.daily;
    int targetCount = 1;

    final emojis = ['✅', '📚', '💪', '🧘', '🏃', '🎯', '✍️', '🎨', '💧', '🥗', '🌅', '🧠', '🎵', '🌱', '💡', '📝'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Handle ───
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.silverLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Yangi odat qo\'shish',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // ─── Emoji Picker ───
              const Text('Belgi', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: emojis.map((emoji) {
                    final isSelected = selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => selectedEmoji = emoji),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.silverLight,
                          ),
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Title ───
              const Text('Nomi', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Masalan: Ertalab yugurish',
                ),
              ),
              const SizedBox(height: 16),

              // ─── Category ───
              const Text('Kategoriya', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: HabitCategory.values.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.silverLight,
                        ),
                      ),
                      child: Text(
                        _categoryLabel(cat),
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ─── Target Count ───
              const Text('Kunlik maqsad', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: targetCount > 1
                        ? () => setState(() => targetCount--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: AppColors.primary,
                  ),
                  Text(
                    '$targetCount',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => targetCount++),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'marta / kun',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Save Button ───
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    final userId = ref.read(currentUserIdProvider);
                    if (userId == null) return;

                    final habit = Habit(
                      id: _uuid.v4(),
                      userId: userId,
                      title: titleController.text.trim(),
                      emoji: selectedEmoji,
                      category: selectedCategory,
                      frequency: selectedFrequency,
                      targetCount: targetCount,
                      createdAt: DateTime.now(),
                    );

                    ref.read(habitNotifierProvider.notifier).createHabit(habit);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Qo\'shish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(HabitCategory cat) {
    switch (cat) {
      case HabitCategory.health:
        return '💪 Sog\'lik';
      case HabitCategory.learning:
        return '📚 O\'rganish';
      case HabitCategory.productivity:
        return '🎯 Samaradorlik';
      case HabitCategory.mindfulness:
        return '🧘 Ruhiyat';
      case HabitCategory.social:
        return '🤝 Ijtimoiy';
      case HabitCategory.creative:
        return '🎨 Ijod';
    }
  }
}

/// ─── Add Habit Button ───
class _AddHabitButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddHabitButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Yangi odat qo\'shish',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
