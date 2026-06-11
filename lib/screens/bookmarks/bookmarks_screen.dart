/// ═══════════════════════════════════════════════════════════════
/// Bookmarks Screen - AZAMOV Academy
/// Saqlangan AI xabarlarni ko'rish
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/bookmark_provider.dart';
import '../../models/bookmark_model.dart';
import '../../widgets/glass_card.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                'Xatcho\'plar 🔖',
                style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 28,
                  fontWeight: FontWeight.w700, letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Muhim AI javoblarini saqlang va qayta o\'qing',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: bookmarks.when(
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔖', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          const Text(
                            'Hali xatcho\'plar yo\'q',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Chatda muhim javoblarni saqlang',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final bookmark = list[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.bookmark_rounded, color: AppColors.academyBlue, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      bookmark.content,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => ref.read(bookmarkNotifierProvider.notifier).deleteBookmark(bookmark.id),
                                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                                  ),
                                ],
                              ),
                              if (bookmark.aiResponse != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.silverLight),
                                  ),
                                  child: Text(
                                    bookmark.aiResponse!,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary, fontSize: 13, height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                              if (bookmark.tag != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(bookmark.tag!, style: const TextStyle(
                                    color: AppColors.academyPurple, fontSize: 11, fontWeight: FontWeight.w500,
                                  )),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
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
}
