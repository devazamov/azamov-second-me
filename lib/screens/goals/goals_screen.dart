/// ═══════════════════════════════════════════════════════════════
/// Goals Board - AZAMOV Academy
/// Maqsadlar taxtasi vizual progress bilan
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../widgets/glass_card.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final goals = user.valueOrNull?.goals ?? [];
    final dreams = user.valueOrNull?.dreams ?? [];
    final interests = user.valueOrNull?.interests ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Maqsadlar 🎯',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Orzularingizni maqsadga aylantiring va kuzatib boring',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Goals section
              const Text(
                'Maqsadlar 📌',
                style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (goals.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text(
                          'Hali maqsadlar yo\'q',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/profile'),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('Maqsad qo\'shish'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...goals.map((goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.flag_rounded, color: AppColors.academyBlue, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(goal, style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600,
                              )),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.3, // placeholder progress
                                  backgroundColor: AppColors.silverLight,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.academyBlue),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

              const SizedBox(height: 24),

              // Dreams section
              const Text(
                'Orzular ✨',
                style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (dreams.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text('Orzular qo\'shilmagan',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  ),
                )
              else
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: dreams.map((dream) => GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌟', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(dream, style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14,
                        )),
                      ],
                    ),
                  )).toList(),
                ),

              const SizedBox(height: 24),

              // Interests section
              const Text(
                'Qiziqishlar 💡',
                style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (interests.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text('Qiziqishlar yo\'q',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  ),
                )
              else
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: interests.map((interest) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.academyPurple.withOpacity(0.2)),
                    ),
                    child: Text(interest, style: const TextStyle(
                      color: AppColors.academyPurple, fontSize: 13, fontWeight: FontWeight.w500,
                    )),
                  )).toList(),
                ),

              const SizedBox(height: 32),

              // AI suggestion
              GlassCard(
                onTap: () => context.go('/chat'),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('AI bilan maslahatlashing',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text('Kelajakdagi o\'zingizdan maqsadlar haqida maslahat oling',
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
