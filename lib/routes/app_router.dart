/// ═══════════════════════════════════════════════════════════════
/// Go Router Configuration - AZAMOV Second Me
/// Navigation setup with authentication guards
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/missions/missions_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/habits/habits_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/focus/focus_timer_screen.dart';
import '../screens/mood/mood_tracker_screen.dart';
import '../screens/challenge/challenge_screen.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/meditation/meditation_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../screens/report/weekly_report_screen.dart';
import '../widgets/main_shell.dart';

/// GoRouter provider with auth redirect
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';

      // Show splash first
      if (isSplash) return null;

      // Not logged in → login page
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Logged in but on auth page → redirect
      if (isLoggedIn && isAuthRoute) {
        // Check if onboarding completed
        final onboardingDone =
            user.valueOrNull?.onboardingCompleted ?? false;
        if (!onboardingDone) return '/onboarding';
        return '/home';
      }

      // Logged in, needs onboarding
      if (isLoggedIn && !isOnboarding) {
        final onboardingDone =
            user.valueOrNull?.onboardingCompleted ?? false;
        if (!onboardingDone) return '/onboarding';
      }

      return null;
    },
    routes: [
      // ─── Splash Screen ───
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ─── Auth Routes ───
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPageTransition(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _buildPageTransition(
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _buildPageTransition(
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),

      // ─── Onboarding ───
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ─── Main Shell with Bottom Navigation ───
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const ChatScreen(),
            ),
          ),
          GoRoute(
            path: '/missions',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const MissionsScreen(),
            ),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const ProgressScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/habits',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const HabitsScreen(),
            ),
          ),
          GoRoute(
            path: '/journal',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const JournalScreen(),
            ),
          ),
          GoRoute(
            path: '/focus',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const FocusTimerScreen(),
            ),
          ),
          GoRoute(
            path: '/mood',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const MoodTrackerScreen(),
            ),
          ),
          GoRoute(
            path: '/challenge',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const ChallengeScreen(),
            ),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const GoalsScreen(),
            ),
          ),
          GoRoute(
            path: '/bookmarks',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const BookmarksScreen(),
            ),
          ),
          GoRoute(
            path: '/meditation',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const MeditationScreen(),
            ),
          ),
          GoRoute(
            path: '/premium',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const PremiumScreen(),
            ),
          ),
          GoRoute(
            path: '/report',
            pageBuilder: (context, state) => _buildPageTransition(
              state: state,
              child: const WeeklyReportScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

/// Custom page transition - Apple-style slide
CustomTransitionPage<void> _buildPageTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}
