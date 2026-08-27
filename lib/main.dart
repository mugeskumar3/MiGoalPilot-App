import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot_app/app/router/app_router.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_theme.dart';
import 'package:migoalpilot_app/core/viewmodels/viewmodels.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MiGoalPilotApp()));
}

class MiGoalPilotApp extends ConsumerWidget {
  const MiGoalPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
    final themeMode = profileState.themeMode;

    final brightness = themeMode == ThemeMode.dark
        ? Brightness.dark
        : (themeMode == ThemeMode.light
              ? Brightness.light
              : MediaQuery.platformBrightnessOf(context));

    final isDark = brightness == Brightness.dark;

    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark
          ? AppColors.backgroundDark
          : AppColors.background,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: MaterialApp.router(
        title: 'MiGoalPilot',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
