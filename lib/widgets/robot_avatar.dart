/// ═══════════════════════════════════════════════════════════════
/// Robot Avatar - AZAMOV Academy
/// Real 3D Lottie Animated Robot Character
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

/// Robot animation states
enum RobotAnimation { idle, talking, happy, thinking }

class RobotAvatar extends StatelessWidget {
  final double size;
  final RobotAnimation animation;
  final bool showGlow;
  final VoidCallback? onTap;

  const RobotAvatar({
    super.key,
    this.size = 100,
    this.animation = RobotAnimation.idle,
    this.showGlow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: AppColors.academyBlue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.academyPurple.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showGlow)
              Container(
                width: size * 0.9,
                height: size * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.academyBlue.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

            // Lottie animation with state switching
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Lottie.asset(
                _getAnimationPath(animation),
                key: ValueKey(animation),
                width: size,
                height: size,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
                errorBuilder: (context, error, stackTrace) =>
                    _fallbackEmoji(),
              ),
            ),

            // Talking indicator
            if (animation == RobotAnimation.talking)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.waves_rounded,
                      color: Colors.white, size: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getAnimationPath(RobotAnimation anim) {
    switch (anim) {
      case RobotAnimation.idle:
        return 'assets/lottie/robot_idle.json';
      case RobotAnimation.talking:
        return 'assets/lottie/robot_talking.json';
      case RobotAnimation.happy:
        return 'assets/lottie/robot_happy.json';
      case RobotAnimation.thinking:
        return 'assets/lottie/robot_thinking.json';
    }
  }

  Widget _fallbackEmoji() {
    switch (animation) {
      case RobotAnimation.idle:
        return Text('🤖', style: TextStyle(fontSize: size * 0.55));
      case RobotAnimation.talking:
        return Text('🧑‍💻', style: TextStyle(fontSize: size * 0.55));
      case RobotAnimation.happy:
        return Text('🎉', style: TextStyle(fontSize: size * 0.55));
      case RobotAnimation.thinking:
        return Text('🤔', style: TextStyle(fontSize: size * 0.55));
    }
  }
}

/// ─── Robot walking widget (home screen) ───
class RobotWalker extends StatefulWidget {
  final VoidCallback? onTap;
  const RobotWalker({super.key, this.onTap});

  @override
  State<RobotWalker> createState() => _RobotWalkerState();
}

class _RobotWalkerState extends State<RobotWalker>
    with SingleTickerProviderStateMixin {
  late AnimationController _walkController;
  late Animation<double> _walkAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _walkAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _walkController, curve: Curves.easeInOut),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _walkController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _walkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _walkController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_walkAnimation.value, _bounceAnimation.value),
            child: Transform.rotate(
              angle: _walkAnimation.value * 0.01,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.academyBlue.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.academyBlue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Lottie.asset(
                        'assets/lottie/robot_idle.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        animate: true,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text('🤖', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AZAMOV AI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.academyBlue,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
