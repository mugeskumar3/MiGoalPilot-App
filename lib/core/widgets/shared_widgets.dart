import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/app/theme/app_spacing.dart';
import 'package:migoalpilot_app/shared/enums/enums.dart';

class MoneyDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool isSecure;
  final String? prefix;

  const MoneyDisplay({
    super.key,
    required this.amount,
    this.style,
    this.isSecure = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecure) {
      return Text('••••••', style: style ?? AppTextStyles.headlineMedium);
    }
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final formatted = formatter.format(amount);
    return Text(
      prefix != null ? '$prefix$formatted' : formatted,
      style:
          style ??
          AppTextStyles.headlineMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.textPrimary
                : AppColors.textPrimaryDark,
          ),
    );
  }
}

class GoalProgress extends StatelessWidget {
  final double progress;
  final double height;
  final Color? color;

  const GoalProgress({
    super.key,
    required this.progress,
    this.height = 6.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: isLight ? AppColors.border : AppColors.borderDark,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

class GoalJourneyProgress extends StatefulWidget {
  final double progress;
  final GoalHealth health;

  const GoalJourneyProgress({
    super.key,
    required this.progress,
    required this.health,
  });

  @override
  State<GoalJourneyProgress> createState() => _GoalJourneyProgressState();
}

class _GoalJourneyProgressState extends State<GoalJourneyProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GoalJourneyProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation =
          Tween<double>(
            begin: oldWidget.progress,
            end: widget.progress,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getHealthColor() {
    switch (widget.health) {
      case GoalHealth.onTrack:
        return AppColors.healthOnTrack;
      case GoalHealth.needsAttention:
        return AppColors.healthAttention;
      case GoalHealth.atRisk:
        return AppColors.healthAtRisk;
      case GoalHealth.completed:
        return AppColors.healthCompleted;
      case GoalHealth.paused:
        return AppColors.healthPaused;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final color = _getHealthColor();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'START',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '25%',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '50%',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '75%',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'TARGET',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    color: isLight ? AppColors.primary : AppColors.primaryDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            AppSpacing.heightXS,
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final currentProgress = _animation.value;
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 3,
                      width: width,
                      decoration: BoxDecoration(
                        color: isLight
                            ? AppColors.border
                            : AppColors.borderDark,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    Container(
                      height: 3,
                      width: width * currentProgress,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        final markerPct = index * 0.25;
                        final isMarkerPassed = currentProgress >= markerPct;
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMarkerPassed
                                ? AppColors
                                      .accent
                                : (isLight
                                      ? AppColors.border
                                      : AppColors.borderDark),
                            border: Border.all(
                              color: isLight
                                  ? Colors.white
                                  : AppColors.surfaceDark,
                              width: 1,
                            ),
                          ),
                        );
                      }),
                    ),
                    if (currentProgress > 0 && currentProgress < 1.0)
                      Positioned(
                        left: (width * currentProgress) - 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isLight
                                ? Colors.white
                                : AppColors.surfaceDark,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.2),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class GoalHealthBadge extends StatelessWidget {
  final GoalHealth health;

  const GoalHealthBadge({super.key, required this.health});

  Color _getColor() {
    switch (health) {
      case GoalHealth.onTrack:
        return AppColors.healthOnTrack;
      case GoalHealth.needsAttention:
        return AppColors.healthAttention;
      case GoalHealth.atRisk:
        return AppColors.healthAtRisk;
      case GoalHealth.completed:
        return AppColors.healthCompleted;
      case GoalHealth.paused:
        return AppColors.healthPaused;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            health.label.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class GoldPriceWidget extends StatelessWidget {
  final double price;
  final double change;
  final String karat;

  const GoldPriceWidget({
    super.key,
    required this.price,
    required this.change,
    this.karat = '22K',
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight ? AppColors.border : AppColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gold $karat',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              PriceChangeIndicator(change: change),
            ],
          ),
          AppSpacing.heightS,
          Text(
            '${formatter.format(price)}/g',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class PriceChangeIndicator extends StatelessWidget {
  final double change;

  const PriceChangeIndicator({super.key, required this.change});

  @override
  Widget build(BuildContext context) {
    final isNegative = change < 0;
    final color = isNegative ? AppColors.error : AppColors.success;
    final bg = color.withValues(alpha: 0.08);
    final icon = isNegative ? Icons.south_east : Icons.north_east;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 2),
          Text(
            '${change.abs().toStringAsFixed(1)}%',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class AiInsightCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onViewDetails;

  const AiInsightCard({
    super.key,
    required this.title,
    required this.description,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.secondary.withValues(alpha: 0.04)
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isLight
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: isLight ? AppColors.secondary : AppColors.primaryDark,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          AppSpacing.heightS,
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight
                  ? AppColors.textPrimary
                  : AppColors.textSecondaryDark,
              height: 1.4,
            ),
          ),
          if (onViewDetails != null) ...[
            AppSpacing.heightS,
            GestureDetector(
              onTap: onViewDetails,
              child: Text(
                'Consult GoalPilot AI →',
                style: AppTextStyles.caption.copyWith(
                  color: isLight ? AppColors.secondary : AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 1.5,
                ),
              )
            : Text(text),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.border.withValues(alpha: 0.5)
            : AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: 140, height: 24),
          AppSpacing.heightM,
          SkeletonLoader(width: double.infinity, height: 160, borderRadius: 12),
          AppSpacing.heightL,
          SkeletonLoader(width: 80, height: 20),
          AppSpacing.heightM,
          SkeletonLoader(width: double.infinity, height: 50, borderRadius: 8),
          AppSpacing.heightS,
          SkeletonLoader(width: double.infinity, height: 50, borderRadius: 8),
          AppSpacing.heightS,
          SkeletonLoader(width: double.infinity, height: 50, borderRadius: 8),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            AppSpacing.heightM,
            const Text(
              'A small turbulence occurred',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.heightXS,
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.heightL,
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✈️', style: TextStyle(fontSize: 40)),
            AppSpacing.heightM,
            Text(
              title,
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.heightXS,
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              AppSpacing.heightL,
              ElevatedButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}

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
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
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

class MiSectionHeader extends StatelessWidget {
  final String title;

  const MiSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: isLight
              ? AppColors.textSecondary
              : AppColors.textSecondaryDark,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          fontSize: 10,
        ),
      ),
    );
  }
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
      color: bgColor.withValues(alpha: t > 0.8 ? 0.98 : 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isLight
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryDark,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Let's move your goals forward.",
                      style: AppTextStyles.caption.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                        fontSize: 12,
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
                  'MiGoalPilot',
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

class AppFadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double delayInMilliseconds;
  final Offset beginOffset;

  const AppFadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 550),
    this.delayInMilliseconds = 0,
    this.beginOffset = const Offset(0.0, 0.05),
  });

  @override
  State<AppFadeInSlide> createState() => _AppFadeInSlideState();
}

class _AppFadeInSlideState extends State<AppFadeInSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.delayInMilliseconds > 0) {
      Future.delayed(
        Duration(milliseconds: widget.delayInMilliseconds.toInt()),
        () {
          if (mounted) _controller.forward();
        },
      );
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
