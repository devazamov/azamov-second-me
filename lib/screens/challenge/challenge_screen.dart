/// ═══════════════════════════════════════════════════════════════
/// Challenge Screen - AZAMOV Second Me
/// Weekly and monthly challenges with progress tracking
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/challenge_provider.dart';
import '../../models/challenge_model.dart';
import '../../widgets/glass_card.dart';

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChallenges = ref.watch(activeChallengesProvider);
    final userChallenges = ref.watch(userChallengesProvider);
    final activeUserC = ref.watch(activeUserChallengesProvider);
    final completedUserC = ref.watch(completedUserChallengesProvider);

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
                'Challenge 🏆',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'O\'zingizni sinab ko\'ring va yutuqlarga erishing',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // ─── Active User Challenges ───
              if (activeUserC.isNotEmpty) ...[
                const Text(
                  'Davom etayotgan challenge\'lar',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...activeUserC.map((uc) => _ActiveChallengeCard(
                      userChallenge: uc,
                      onCompleteDay: () {
                        ref
                            .read(challengeNotifierProvider.notifier)
                            .completeDay(uc);
                      },
                    )),
                const SizedBox(height: 24),
              ],

              // ─── Completed Challenges ───
              if (completedUserC.isNotEmpty) ...[
                const Text(
                  'Bajarilgan challenge\'lar',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: completedUserC.map((uc) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(uc.challengeEmoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 6),
                            Text(
                              uc.challengeTitle,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${uc.completedDays.length}/${uc.totalDays}',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ─── Available Challenges ───
              const Text(
                'Mavjud challenge\'lar',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              activeChallenges.when(
                data: (challenges) {
                  if (challenges.isEmpty) {
                    return GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text(
                              'Hozircha challenge\'lar yo\'q',
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

                  // Filter out already joined
                  final joinedIds = userChallenges.valueOrNull?.map((u) => u.challengeId).toSet() ?? {};
                  final available = challenges.where((c) => !joinedIds.contains(c.id)).toList();

                  if (available.isEmpty) {
                    return const GlassCard(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Barcha challenge\'larga qo\'shildingiz!',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: available.map((challenge) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ChallengeCard(
                        challenge: challenge,
                        onJoin: () {
                          ref
                              .read(challengeNotifierProvider.notifier)
                              .joinChallenge(challenge);
                        },
                      ),
                    )).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Xatolik: $e')),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── Active Challenge Card ───
class _ActiveChallengeCard extends StatelessWidget {
  final UserChallenge userChallenge;
  final VoidCallback onCompleteDay;

  const _ActiveChallengeCard({
    required this.userChallenge,
    required this.onCompleteDay,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().day;
    final currentDayIndex = userChallenge.currentDay;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(userChallenge.challengeEmoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userChallenge.challengeTitle,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${userChallenge.period == ChallengePeriod.weekly ? 'Haftalik' : 'Oylik'} • ${userChallenge.totalDays} kun',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(userChallenge.progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Progress Bar ───
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: userChallenge.progress,
                backgroundColor: AppColors.silverLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),

            // ─── Day Grid ───
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(userChallenge.totalDays, (index) {
                  final dayNum = index + 1;
                  final isCompleted = userChallenge.completedDays.contains(dayNum);
                  final isToday = dayNum == currentDayIndex && !isCompleted;

                  return Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.successLight
                          : isToday
                              ? AppColors.primaryLight
                              : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.success
                            : isToday
                                ? AppColors.primary
                                : AppColors.silverLight,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check_rounded, color: AppColors.success, size: 16)
                          : Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isToday ? AppColors.primary : AppColors.textMuted,
                              ),
                            ),
                    ),
                  );
                }),
              ),
            ),

            // ─── Today's Task ───
            if (!userChallenge.completedDays.contains(currentDayIndex)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCompleteDay,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text('${currentDayIndex}-kunni bajarish'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ─── Available Challenge Card ───
class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onJoin;

  const _ChallengeCard({
    required this.challenge,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(challenge.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Tag(label: challenge.periodLabel, color: AppColors.primary),
                    const SizedBox(width: 6),
                    _Tag(label: challenge.difficultyLabel, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Text(
                      '${challenge.totalDays} kun',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '+${challenge.xpReward} XP${challenge.bonusXp > 0 ? ' (+${challenge.bonusXp} bonus)' : ''}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onJoin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Qo\'shilish',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
