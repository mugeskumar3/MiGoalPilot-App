import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';

class MainNavigationShell extends StatefulWidget {
  final Widget child;

  const MainNavigationShell({super.key, required this.child});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/goals')) return 1;
    if (location.startsWith('/gold')) return 2;
    if (location.startsWith('/activity')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/goals');
        break;
      case 2:
        context.go('/gold');
        break;
      case 3:
        context.go('/activity');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Bottom spacing to avoid overlapping the floating dock.
    // Dock height is 68, bottom offset is SafeArea + 16, margin is 12.
    final bottomPadding = MediaQuery.of(context).padding.bottom + 96;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      body: Stack(
        children: [
          // Content Area with bottom padding to prevent content from hiding behind the dock
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardVisible ? 0 : bottomPadding),
              child: widget.child,
            ),
          ),

          // Floating Action Button (+ / ₹) above the dock — only on Home & Goals
          if (!keyboardVisible && (selectedIndex == 0 || selectedIndex == 1))
            Positioned(
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 92,
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: () {
                    context.push('/goal-selection');
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isLight ? AppColors.primary : AppColors.accentDark,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isLight ? AppColors.primary : AppColors.accentDark).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: isLight ? Colors.white : AppColors.backgroundDark,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Floating Dock Navigation Bar
          if (!keyboardVisible)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: isLight ? AppColors.surface : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isLight
                          ? AppColors.primary.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(0, Icons.compass_calibration_outlined, Icons.compass_calibration_rounded, 'Home', selectedIndex, context),
                    _buildNavItem(1, Icons.explore_outlined, Icons.explore_rounded, 'Goals', selectedIndex, context),
                    _buildNavItem(2, Icons.toll_outlined, Icons.toll_rounded, 'Gold', selectedIndex, context),
                    _buildNavItem(3, Icons.insights_outlined, Icons.insights_rounded, 'Activity', selectedIndex, context),
                    _buildNavItem(4, Icons.face_outlined, Icons.face_rounded, 'Profile', selectedIndex, context),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
    int selectedIndex,
    BuildContext context,
  ) {
    final active = index == selectedIndex;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final activeColor = isLight ? AppColors.primary : AppColors.accentDark;
    final inactiveColor = isLight ? AppColors.textSecondary : AppColors.textLightDark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(index, context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active 
              ? (isLight ? AppColors.primary.withValues(alpha: 0.06) : AppColors.accentDark.withValues(alpha: 0.12))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? selectedIcon : icon,
              color: active ? activeColor : inactiveColor,
              size: 22,
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: activeColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
