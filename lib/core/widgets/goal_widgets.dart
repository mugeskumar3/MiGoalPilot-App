import 'package:flutter/material.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

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
      duration: const Duration(milliseconds: 1400),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final val = _animation.value;
                final filledWidth = width * val;

                return Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    // Background track (Forest/Sage path)
                    Container(
                      height: 4,
                      width: width,
                      decoration: BoxDecoration(
                        color: isLight
                            ? const Color(0xFFE5DFD0)
                            : AppColors.borderDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Progress line (Sage or Forest)
                    Container(
                      height: 4,
                      width: filledWidth,
                      decoration: BoxDecoration(
                        color: isLight ? AppColors.secondary : color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // 0%, 50%, 100% Markers
                    Positioned(
                      left: 0,
                      child: _buildPoint(val >= 0.0, isLight),
                    ),
                    Positioned(
                      left: width * 0.5 - 4,
                      child: _buildPoint(val >= 0.5, isLight),
                    ),
                    Positioned(
                      right: 0,
                      child: _buildPoint(val >= 1.0, isLight, isTarget: true),
                    ),
                    // Current Position Indicator (Flight node)
                    if (val > 0.0 && val < 1.0)
                      Positioned(
                        left: filledWidth - 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isLight ? AppColors.accent : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLight ? AppColors.primary : color,
                              width: 3.5,
                            ),
                            boxShadow: isLight
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SAVED ${(widget.progress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'TARGET 100%',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: isLight
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPoint(bool active, bool isLight, {bool isTarget = false}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppColors.accent
            : (isLight
                  ? const Color(0xFFC5C0B0)
                  : Colors.grey.withValues(alpha: 0.4)),
        border: Border.all(
          color: isLight ? AppColors.surface : Colors.white,
          width: 1.5,
        ),
      ),
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
