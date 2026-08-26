import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot_app/app/router/app_router.dart';
import 'package:migoalpilot_app/app/theme/app_theme.dart';
import 'package:migoalpilot_app/core/viewmodels/viewmodels.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MiGoalPilotApp(),
    ),
  );
}

class MiGoalPilotApp extends ConsumerWidget {
  const MiGoalPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    return MaterialApp.router(
      title: 'MiGoalPilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: profileState.themeMode,
      routerConfig: appRouter,
    );
  }
}
