import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/router/main_navigation_shell.dart';
import 'package:migoalpilot/features/auth_views.dart';
import 'package:migoalpilot/features/dashboard_views.dart';
import 'package:migoalpilot/features/marriage_views.dart';
import 'package:migoalpilot/features/gold_views.dart';
import 'package:migoalpilot/features/ai_views.dart';
import 'package:migoalpilot/features/couple_views.dart';
import 'package:migoalpilot/features/profile_views.dart';
import 'package:migoalpilot/features/edit_profile_views.dart';
import 'package:migoalpilot/features/profile_detail_views.dart';
import 'package:migoalpilot/features/multi_goal_views.dart';
import 'package:migoalpilot/features/legal_views.dart';
import 'package:migoalpilot/app/constants/app_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    GoRoute(
      path: '/onboarding/:step',
      builder: (context, state) {
        final stepStr = state.pathParameters['step'] ?? '1';
        final step = int.tryParse(stepStr) ?? 1;
        return OnboardingScreen(step: step);
      },
    ),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    ShellRoute(
      builder: (context, state, child) => MainNavigationShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const HomeDashboardScreen(),
        ),

        GoRoute(
          path: '/goals',
          builder: (context, state) => const GoalsScreen(),
        ),

        GoRoute(
          path: '/gold',
          builder: (context, state) => const GoldDashboardScreen(),
        ),

        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityScreen(),
        ),

        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    GoRoute(
      path: '/goal-selection',
      builder: (context, state) => const GoalSelectionScreen(),
    ),

    GoRoute(
      path: '/ai-goal-creation',
      builder: (context, state) => const AiGoalCreationScreen(),
    ),

    GoRoute(
      path: '/create-goal',
      builder: (context, state) => const CreateGoalScreen(),
    ),

    GoRoute(
      path: '/goals/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return GoalDetailScreen(goalId: id);
      },
    ),

    GoRoute(
      path: '/add-saving/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AddSavingScreen(goalId: id);
      },
    ),

    GoRoute(
      path: '/marriage-planner',
      builder: (context, state) => const MarriagePlannerScreen(),
    ),

    GoRoute(
      path: '/marriage-budget',
      builder: (context, state) => const MarriageBudgetScreen(),
    ),

    GoRoute(
      path: '/marriage-timeline',
      builder: (context, state) => const MarriageTimelineScreen(),
    ),

    GoRoute(
      path: '/what-if-simulator',
      builder: (context, state) => const WhatIfSimulatorScreen(),
    ),

    GoRoute(
      path: '/gold-goals/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return GoldGoalDetailScreen(goalId: id);
      },
    ),

    GoRoute(
      path: '/gold-alerts',
      builder: (context, state) => const GoldAlertSettingsScreen(),
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: '/ai',
      builder: (context, state) => const AiAssistantScreen(),
    ),

    GoRoute(
      path: '/couple-mode',
      builder: (context, state) => const CoupleModeScreen(),
    ),

    GoRoute(
      path: '/invite-partner',
      builder: (context, state) => const InvitePartnerScreen(),
    ),

    GoRoute(
      path: '/security',
      builder: (context, state) => const SecurityScreen(),
    ),

    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),

    GoRoute(
      path: '/theme-settings',
      builder: (context, state) => const ThemeSettingsScreen(),
    ),

    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),

    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    GoRoute(
      path: '/profile-detail',
      builder: (context, state) => const ProfileDetailScreen(),
    ),

    GoRoute(
      path: '/multi-goal',
      builder: (context, state) => const MultiGoalScreen(),
    ),

    GoRoute(
      path: '/help',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text(
            'Help & Support Center\nContact support at contact@migoalpilot.com',
          ),
        ),
      ),
    ),

    GoRoute(
      path: '/about',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text(
            '${AppConstants.appName} v1.0.0\nFly Closer to Your Dreams. ✈️',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  ],
);
