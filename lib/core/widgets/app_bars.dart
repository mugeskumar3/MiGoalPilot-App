import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/app/constants/app_constants.dart';

class MiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  const MiAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AppBar(
      title: Column(
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isLight
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(
                color: isLight
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class MiBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const MiBackAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20),
        onPressed: onBackPressed ?? () => context.pop(),
      ),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class MiSliverAppBar extends StatelessWidget {
  final String userName;
  final String avatarInitials;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const MiSliverAppBar({
    super.key,
    required this.userName,
    this.avatarInitials = 'M',
    this.onAvatarTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _MiSliverAppBarDelegate(
        topPadding: topPadding,
        userName: userName,
        avatarInitials: avatarInitials,
        onAvatarTap: onAvatarTap,
        onNotificationTap: onNotificationTap,
        isLight: Theme.of(context).brightness == Brightness.light,
      ),
    );
  }
}

class _MiSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String userName;
  final String avatarInitials;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final bool isLight;

  _MiSliverAppBarDelegate({
    required this.topPadding,
    required this.userName,
    required this.avatarInitials,
    this.onAvatarTap,
    this.onNotificationTap,
    required this.isLight,
  });

  @override
  double get minExtent => 60.0 + topPadding;

  @override
  double get maxExtent => 130.0 + topPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double currentMax = maxExtent;
    final double currentMin = minExtent;
    final double delta = currentMax - currentMin;
    final double t = (shrinkOffset / delta).clamp(0.0, 1.0);

    final double avatarSize = 44.0 + (32.0 - 44.0) * t;

    final bgColor = isLight ? AppColors.background : AppColors.backgroundDark;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        gradient: isLight && t < 0.8
            ? RadialGradient(
                center: const Alignment(-0.8, -0.6),
                radius: 1.8,
                colors: [
                  const Color(0xFFFFFDF9).withValues(alpha: 1.0 - t),
                  AppColors.background.withValues(alpha: 1.0 - t),
                ],
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1.0 - t * 2.0).clamp(0.0, 1.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Good morning,\n$userName 👋',
                      style: AppTextStyles.displayLarge.copyWith(
                        fontSize: isLight ? 28 : 22,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.primary
                            : AppColors.textPrimaryDark,
                        height: 1.15,
                        letterSpacing: isLight ? -0.8 : -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Let's move your goals forward.",
                      style: AppTextStyles.caption.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                        fontSize: 12.5,
                        fontWeight: isLight
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: (t - 0.5).clamp(0.0, 1.0) * 2.0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppConstants.appName,
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isLight ? AppColors.primary : AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onNotificationTap != null && t > 0.6) ...[
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none_outlined,
                        color: isLight
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryDark,
                        size: 22,
                      ),
                      onPressed: onNotificationTap,
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLight ? Colors.white : AppColors.surfaceDark,
                        border: Border.all(
                          color: AppColors.accent,
                          width: t > 0.5 ? 1.0 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          avatarInitials,
                          style: TextStyle(
                            fontSize: avatarSize * 0.4,
                            fontWeight: FontWeight.bold,
                            color: isLight
                                ? AppColors.primary
                                : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MiSliverAppBarDelegate oldDelegate) {
    return oldDelegate.userName != userName ||
        oldDelegate.avatarInitials != avatarInitials ||
        oldDelegate.isLight != isLight;
  }
}
