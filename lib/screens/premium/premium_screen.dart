/// ═══════════════════════════════════════════════════════════════
/// Premium Screen - AZAMOV Academy
/// Click/Uzum to'lov tizimi orqali premium obuna
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/robot_avatar.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const _features = [
    {'icon': '🤖', 'title': 'Cheksiz AI Chat', 'desc': 'Kunlik limit yo\'q'},
    {'icon': '📊', 'title': 'Batafsil Analitika', 'desc': 'Chuqur statistika va hisobotlar'},
    {'icon': '🏆', 'title': 'Premium Challenge', 'desc': 'Maxsus challenge va vazifalar'},
    {'icon': '🎨', 'title': 'Maxsus Dizayn', 'desc': 'Eksklyuziv temalar va avatar'},
    {'icon': '📤', 'title': 'Ma\'lumotlarni Export', 'desc': 'PDF va rasm sifatida yuklab olish'},
    {'icon': '🧘', 'title': 'Premium Meditatsiya', 'desc': 'Barcha nafas olish mashqlari'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Robot + Header
              const RobotAvatar(size: 80, animation: RobotAnimation.happy),
              const SizedBox(height: 16),
              const Text(
                'AZAMOV Academy Premium',
                style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'O\'zingizning eng yaxshi versiyangizga erishing',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Price card
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderColor: AppColors.academyGold.withOpacity(0.3),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.academyBlue.withOpacity(0.05), AppColors.academyPurple.withOpacity(0.05)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('OYLIK OBUNA',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('so\'m', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                          ),
                          Text('49,000',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 48, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('/oy', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppColors.premiumGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('15% CHEGIRMA!',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Features
              const Text('Premium imkoniyatlar',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ..._features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(f['icon']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f['title']!,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            Text(f['desc']!,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                    ],
                  ),
                ),
              )),

              const SizedBox(height: 24),

              // Payment methods
              const Text('To\'lov usuli',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.monetization_on_rounded, color: AppColors.academyBlue, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Click / Uzum',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          Text('Telefon raqam orqali to\'lov',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Subscribe button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('https://click.uz');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.diamond_rounded),
                  label: const Text('Premiumga o\'tish'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppColors.academyBlue,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'To\'lov bir martalik. Istatgan vaqt bekor qilishingiz mumkin',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
