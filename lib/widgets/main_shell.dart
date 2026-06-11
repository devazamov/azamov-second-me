/// ═══════════════════════════════════════════════════════════════
/// Main Shell - AZAMOV Second Me
/// Bottom navigation shell for main app screens
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/missions')) return 2;
    if (location.startsWith('/habits')) return 3;
    if (location.startsWith('/progress')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/missions');
        break;
      case 3:
        context.go('/habits');
        break;
      case 4:
        context.go('/progress');
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.silverLight,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home_rounded,
                  label: 'Bosh',
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                ),
                _NavItem(
                  icon: Icons.flag_outlined,
                  activeIcon: Icons.flag_rounded,
                  label: 'Vazifalar',
                  isActive: currentIndex == 2,
                  onTap: () => _onTap(context, 2),
                ),
                _NavItem(
                  icon: Icons.checklist_rounded,
                  activeIcon: Icons.checklist_rounded,
                  label: 'Odatlar',
                  isActive: currentIndex == 3,
                  onTap: () => _onTap(context, 3),
                ),
                _NavItem(
                  icon: Icons.trending_up_rounded,
                  activeIcon: Icons.trending_up_rounded,
                  label: 'Progress',
                  isActive: currentIndex == 4,
                  onTap: () => _onTap(context, 4),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil',
                  isActive: currentIndex == 5,
                  onTap: () => _onTap(context, 5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ─── Custom Navigation Item ───
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
