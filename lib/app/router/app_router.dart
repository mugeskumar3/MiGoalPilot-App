import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot_app/app/router/main_navigation_shell.dart';
import 'package:migoalpilot_app/features/auth_views.dart';
import 'package:migoalpilot_app/features/dashboard_views.dart';
import 'package:migoalpilot_app/features/marriage_views.dart';
import 'package:migoalpilot_app/features/gold_views.dart';
import 'package:migoalpilot_app/features/ai_views.dart';
import 'package:migoalpilot_app/features/couple_views.dart';
import 'package:migoalpilot_app/features/profile_views.dart';
import 'package:migoalpilot_app/features/multi_goal_views.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 1. Splash
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // 2, 3, 4. Onboarding steps
    GoRoute(
      path: '/onboarding/:step',
      builder: (context, state) {
        final stepStr = state.pathParameters['step'] ?? '1';
        final step = int.tryParse(stepStr) ?? 1;
        return OnboardingScreen(step: step);
      },
    ),

    // 5. Login
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // 6. Register
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // 7. Forgot Password
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Shell routes for Main Navigation Tabs
    ShellRoute(
      builder: (context, state, child) => MainNavigationShell(child: child),
      routes: [
        // 10. Home Dashboard
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const HomeDashboardScreen(),
        ),

        // 11. Goals List
        GoRoute(
          path: '/goals',
          builder: (context, state) => const GoalsScreen(),
        ),

        // 19. Gold Dashboard
        GoRoute(
          path: '/gold',
          builder: (context, state) => const GoldDashboardScreen(),
        ),

        // 23. Activity History
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityScreen(),
        ),

        // 28. Profile Screen
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // 8. Goal Selection
    GoRoute(
      path: '/goal-selection',
      builder: (context, state) => const GoalSelectionScreen(),
    ),

    // 9. AI Goal Creation
    GoRoute(
      path: '/ai-goal-creation',
      builder: (context, state) => const AiGoalCreationScreen(),
    ),

    // 12. Create Goal
    GoRoute(
      path: '/create-goal',
      builder: (context, state) => const CreateGoalScreen(),
    ),

    // 13. Goal Detail
    GoRoute(
      path: '/goals/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return GoalDetailScreen(goalId: id);
      },
    ),

    // 14. Add Saving
    GoRoute(
      path: '/add-saving/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AddSavingScreen(goalId: id);
      },
    ),

    // 15. Marriage Planner
    GoRoute(
      path: '/marriage-planner',
      builder: (context, state) => const MarriagePlannerScreen(),
    ),

    // 16. Marriage Budget
    GoRoute(
      path: '/marriage-budget',
      builder: (context, state) => const MarriageBudgetScreen(),
    ),

    // 17. Marriage Timeline
    GoRoute(
      path: '/marriage-timeline',
      builder: (context, state) => const MarriageTimelineScreen(),
    ),

    // 18. What-If Simulator
    GoRoute(
      path: '/what-if-simulator',
      builder: (context, state) => const WhatIfSimulatorScreen(),
    ),

    // 21. Gold Goal Detail
    GoRoute(
      path: '/gold-goals/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return GoldGoalDetailScreen(goalId: id);
      },
    ),

    // 22. Gold Alert Settings
    GoRoute(
      path: '/gold-alerts',
      builder: (context, state) => const GoldAlertSettingsScreen(),
    ),

    // 24. Notifications
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // 25. AI Assistant
    GoRoute(
      path: '/ai',
      builder: (context, state) => const AiAssistantScreen(),
    ),

    // 26. Couple Mode Settings
    GoRoute(
      path: '/couple-mode',
      builder: (context, state) => const CoupleModeScreen(),
    ),

    // 27. Invite Partner
    GoRoute(
      path: '/invite-partner',
      builder: (context, state) => const InvitePartnerScreen(),
    ),

    // 29. Security Options
    GoRoute(
      path: '/security',
      builder: (context, state) => const SecurityScreen(),
    ),

    // 30. Notification Preferences
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),

    // 31. Theme Mode Preferences
    GoRoute(
      path: '/theme-settings',
      builder: (context, state) => const ThemeSettingsScreen(),
    ),

    // 32. Privacy Policy Page
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),

    // 33. Multi Goal Balance Plan
    GoRoute(
      path: '/multi-goal',
      builder: (context, state) => const MultiGoalScreen(),
    ),

    // Help Center Stub
    GoRoute(
      path: '/help',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Help & Support Center\nContact support at contact@migoalpilot.com')),
      ),
    ),

    // About App Stub
    GoRoute(
      path: '/about',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text(
            'MiGoalPilot v1.0.0\nFly Closer to Your Dreams. ✈️',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  ],
);
