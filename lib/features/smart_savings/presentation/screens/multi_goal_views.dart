import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_spacing.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';

class MultiGoalScreen extends ConsumerWidget {
  const MultiGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(smartSavingsPlanViewModelProvider);
    final notifier = ref.read(smartSavingsPlanViewModelProvider.notifier);
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (state.isLoading) {
      return const Scaffold(body: LoadingState());
    }

    if (state.goals.isEmpty) {
      return Scaffold(
        appBar: MiBackAppBar(
          title: 'Smart Savings Plan',
          onBackPressed: () => context.pop(),
        ),
        body: const EmptyState(
          title: 'No Active Goals Yet',
          description:
              'Create at least one goal to configure your Smart Savings Plan.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Smart Savings Plan',
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MONTHLY SAVINGS COCKPIT',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: isLight ? AppColors.primary : AppColors.primaryDark,
                letterSpacing: 1.2,
              ),
            ),
            AppSpacing.heightS,
            Text(
              'Balance monthly saving capacity dynamically across all active goals to optimize trajectories and timelines.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLight
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 24),

            // Premium Total Capacity Display Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLight
                      ? [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.85),
                        ]
                      : [AppColors.surfaceDark, AppColors.elevatedSurfaceDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your recommended monthly saving',
                    style: AppTextStyles.caption.copyWith(
                      color: isLight
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textSecondaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MoneyDisplay(
                        amount: state.totalCapacity,
                        style: AppTextStyles.displayMedium.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isLight
                              ? Colors.white
                              : AppColors.textPrimaryDark,
                        ),
                      ),
                      Text(
                        '/ month',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isLight
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'GOAL ALLOCATIONS',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isLight
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 12),

            // Goal Allocations List with Interactive Adjustments
            ...state.goals.map((g) {
              final double allocation = state.allocations[g.id] ?? 0.0;
              final double percentage = state.totalCapacity > 0
                  ? (allocation / state.totalCapacity * 100)
                  : 0.0;
              final int simulatedScore =
                  state.simulatedHealthScores[g.id] ?? 100;
              final DateTime? projectedDate =
                  state.projectedCompletionDates[g.id];

              // Projections diff message compared to original targetDate
              String projectionMessage = '';
              if (projectedDate != null) {
                final diffMonths =
                    ((g.targetDate.difference(projectedDate).inDays) / 30.4368)
                        .round();
                if (diffMonths > 0) {
                  projectionMessage =
                      'Reach your milestone $diffMonths months earlier!';
                } else if (diffMonths < 0) {
                  projectionMessage =
                      'Projected delay: ${diffMonths.abs()} months behind target.';
                } else {
                  projectionMessage = 'On track to meet target date.';
                }
              } else {
                projectionMessage =
                    'Goal timeline is paused (zero monthly saving).';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              g.type.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              g.name,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLight
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryDark,
                              ),
                            ),
                          ],
                        ),
                        // Simulated health score indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (simulatedScore >= 60
                                        ? AppColors.success
                                        : AppColors.warning)
                                    .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Score: $simulatedScore',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: simulatedScore >= 60
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}% of budget',
                          style: AppTextStyles.caption.copyWith(
                            color: isLight
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                        MoneyDisplay(
                          amount: allocation,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isLight
                                ? AppColors.primary
                                : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Proportional slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: isLight
                            ? AppColors.primary
                            : AppColors.primaryDark,
                        inactiveTrackColor: isLight
                            ? AppColors.border
                            : AppColors.borderDark,
                        thumbColor: isLight
                            ? AppColors.accent
                            : AppColors.accentDark,
                        overlayColor: AppColors.primary.withValues(alpha: 0.12),
                      ),
                      child: Slider(
                        min: 0,
                        max: state.totalCapacity,
                        value: allocation.clamp(0.0, state.totalCapacity),
                        onChanged: (val) {
                          notifier.updateAllocation(g.id, val);
                        },
                      ),
                    ),
                    if (projectionMessage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        projectionMessage,
                        style: AppTextStyles.caption.copyWith(
                          color: projectionMessage.contains('delay')
                              ? AppColors.error
                              : (projectionMessage.contains('earlier')
                                    ? AppColors.success
                                    : AppColors.textSecondary),
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Smart recommendation text card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLight
                    ? AppColors.primary.withValues(alpha: 0.04)
                    : AppColors.primaryDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLight
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.primaryDark.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CO-PILOT REBALANCING ADVICE',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLight
                          ? AppColors.primary
                          : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.recommendationText,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isLight
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            PrimaryButton(
              text: 'ACCEPT PLAN',
              onPressed: () async {
                await notifier.savePlan();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cockpit rebalancing plan updated successfully!',
                      ),
                    ),
                  );
                  context.pop();
                }
              },
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              text: 'Adjust Plan Parameters',
              onPressed: () => notifier.initPlan(),
            ),
          ],
        ),
      ),
    );
  }
}
